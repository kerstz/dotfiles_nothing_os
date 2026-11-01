import math

import cairo
import numpy as np
from PIL import Image, ImageFilter

PAPER = np.array([232, 221, 204], dtype=np.float32)
RIM = np.array([248, 242, 231], dtype=np.float32)
EDGE = np.array([176, 158, 130], dtype=np.float32)
INK = (0.13, 0.13, 0.14)
INK_SOFT = (0.24, 0.23, 0.22)


def fractal(shape, beta, rng, aniso=(1.0, 1.0)):
    h, w = shape
    white = rng.standard_normal((h, w))
    fy = np.fft.fftfreq(h)[:, None] * aniso[0] * h / max(h, w)
    fx = np.fft.rfftfreq(w)[None, :] * aniso[1] * w / max(h, w)
    f = np.sqrt(fx * fx + fy * fy)
    f[0, 0] = 1.0
    spec = np.fft.rfft2(white) / np.power(f, beta)
    spec[0, 0] = 0
    out = np.fft.irfft2(spec, s=(h, w))
    return (out / (out.std() + 1e-6)).astype(np.float32)


def smoothstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def tile(field, h, w, oy=0, ox=0):
    fh, fw = field.shape
    ys = (np.arange(h) - oy) % fh
    xs = (np.arange(w) - ox) % fw
    return field[np.ix_(ys, xs)]


def rect_inner_distance(h, w, m, r, cut=""):
    y, x = np.mgrid[0:h, 0:w].astype(np.float32)
    left = m if "l" not in cut else -500
    right = w - m if "r" not in cut else w + 500
    top = m if "t" not in cut else -500
    bottom = h - m if "b" not in cut else h + 500
    cx, cy = (left + right) / 2, (top + bottom) / 2
    hx, hy = (right - left) / 2 - r, (bottom - top) / 2 - r
    qx, qy = np.abs(x - cx) - hx, np.abs(y - cy) - hy
    outside = np.hypot(np.maximum(qx, 0), np.maximum(qy, 0))
    inside = np.minimum(np.maximum(qx, qy), 0)
    return -(outside + inside - r)


def paper_body(h, w, rng, base=PAPER, oy=0, ox=0, period=None):
    ph, pw = (period, period) if period else (h, w)
    mott = tile(fractal((ph, pw), 1.35, rng), h, w, oy, ox)
    fib = tile(fractal((ph, pw), 0.9, rng, aniso=(0.12, 2.6)), h, w, oy, ox)
    fine = tile(fractal((ph, pw), 0.25, rng), h, w, oy, ox)
    fibv = tile(fractal((ph, pw), 0.8, rng, aniso=(2.2, 0.15)), h, w, oy, ox)
    speck = tile(fractal((ph, pw), 0.1, rng), h, w, oy, ox)
    delta = mott * 2.0 + fib * 0.95 + fibv * 0.45 + fine * 0.9
    delta -= np.clip(speck - 3.1, 0, 2) * 15
    rgb = np.stack([base[0] + delta, base[1] + delta * 1.03, base[2] + delta * 1.1], axis=-1)
    return rgb


def compose_sheet(h, w, seed, margin=28, amp=2.6, rim=3.0, radius=10, cut="", period=None, oy=0, ox=0,
                  base=PAPER, shadow=(0, 5, 9, 0.5), rim_amt=0.62, edge_amt=0.62):
    rng = np.random.default_rng(seed)
    ph, pw = (period, period) if period else (h, w)
    big = tile(fractal((ph, pw), 1.75, rng), h, w, oy, ox)
    mid = tile(fractal((ph, pw), 1.15, rng), h, w, oy, ox)
    small = tile(fractal((ph, pw), 0.55, rng), h, w, oy, ox)
    d = rect_inner_distance(h, w, margin, radius, cut)
    dn = d + big * amp * 1.0 + mid * amp * 0.34 + small * 0.48
    alpha = smoothstep(0.0, 1.5, dn)
    rgb = paper_body(h, w, rng, base, oy, ox, period)

    inner = np.clip(1 - dn / 34, 0, 1) ** 2
    rgb = rgb - inner[..., None] * np.array([7, 8.5, 10], dtype=np.float32)

    rim_w = rim * (1.0 + 0.55 * np.tanh(tile(fractal((ph, pw), 0.95, rng), h, w, oy, ox)))
    rim_mask = 1 - smoothstep(rim_w * 0.55, rim_w * 1.15, dn)
    rgb = rgb * (1 - rim_mask[..., None] * rim_amt) + RIM[None, None, :] * rim_mask[..., None] * rim_amt
    edge_mask = (1 - smoothstep(0.2, 2.0, dn)) * (0.45 + 0.55 * smoothstep(-0.5, 0.8, small))
    rgb = rgb * (1 - edge_mask[..., None] * edge_amt) + EDGE[None, None, :] * edge_mask[..., None] * edge_amt

    out = np.dstack([np.clip(rgb, 0, 255), alpha * 255]).astype(np.uint8)
    img = Image.fromarray(out, "RGBA")
    if shadow:
        ox_s, oy_s, blur, op = shadow
        sa = Image.fromarray((alpha * 255).astype(np.uint8), "L").filter(ImageFilter.GaussianBlur(blur))
        sa = np.asarray(sa, dtype=np.float32) / 255 * op
        sa = np.roll(np.roll(sa, oy_s, axis=0), ox_s, axis=1)
        if oy_s > 0:
            sa[:oy_s, :] = 0
        if ox_s > 0:
            sa[:, :ox_s] = 0
        canvas = np.zeros((h, w, 4), dtype=np.float32)
        canvas[..., 0:3] = np.array([16, 14, 12], dtype=np.float32)
        canvas[..., 3] = sa * 255
        under = Image.fromarray(canvas.astype(np.uint8), "RGBA")
        under.alpha_composite(img)
        img = under
    return img


def fold_corner(img, corner="tr", size=26, margin=28):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, img.width, img.height)
    ctx = cairo.Context(surf)
    x = img.width - margin if "r" in corner else margin
    y = margin if "t" in corner else img.height - margin
    sx = -1 if "r" in corner else 1
    sy = 1 if "t" in corner else -1
    ctx.move_to(x + sx * size, y)
    ctx.line_to(x + sx * size * 0.86, y + sy * size * 0.86)
    ctx.line_to(x, y + sy * size)
    ctx.close_path()
    ctx.set_source_rgba(0.96, 0.93, 0.87, 1)
    ctx.fill_preserve()
    ctx.set_source_rgba(0.45, 0.40, 0.33, 0.55)
    ctx.set_line_width(1.1)
    ctx.stroke()
    surf.flush()
    arr = np.ndarray((img.height, img.width, 4), dtype=np.uint8, buffer=surf.get_data())
    layer = Image.fromarray(arr[..., [2, 1, 0, 3]].copy(), "RGBA")
    out = img.copy()
    out.alpha_composite(layer)
    return out


def make_tape(path, w, h, color, seed, alpha=0.8):
    rng = np.random.default_rng(seed)
    n = fractal((h, w), 0.9, rng, aniso=(0.25, 2.2))
    c = np.array(color, dtype=np.float32)
    rgb = c[None, None, :] + n[..., None] * 3.5
    y, x = np.mgrid[0:h, 0:w].astype(np.float32)
    jag = fractal((h, 2), 0.6, rng)
    left = 4 + np.abs(jag[:, 0]) * 3
    right = w - 4 - np.abs(jag[:, 1]) * 3
    ax = smoothstep(0, 1.2, x - left[:, None]) * smoothstep(0, 1.2, right[:, None] - x)
    wav = fractal((2, w), 1.2, rng)
    top = 3 + wav[0, :] * 1.0
    bot = h - 3 + wav[1, :] * 1.0
    ay = smoothstep(0, 1.2, y - top[None, :]) * smoothstep(0, 1.2, bot[None, :] - y)
    a = ax * ay * (alpha + n * 0.03)
    out = np.dstack([np.clip(rgb, 0, 255), np.clip(a, 0, 1) * 255]).astype(np.uint8)
    Image.fromarray(out, "RGBA").save(path, optimize=True)


class Pen:
    def __init__(self, ctx, color=INK, w=1.6, wob=0.2, seed=1, step=1.2):
        self.ctx = ctx
        self.color = color
        self.w = w
        self.wob = wob
        self.step = step
        self.rng = np.random.default_rng(seed)
        ctx.set_line_cap(cairo.LINE_CAP_ROUND)
        ctx.set_line_join(cairo.LINE_JOIN_ROUND)

    @staticmethod
    def _catmull(pts, closed, samples=14):
        p = np.asarray(pts, dtype=np.float64)
        if closed:
            p = np.vstack([p[-1], p, p[0], p[1]])
        else:
            p = np.vstack([p[0], p, p[-1]])
        out = []
        for i in range(len(p) - 3):
            p0, p1, p2, p3 = p[i:i + 4]
            t = np.linspace(0, 1, samples, endpoint=False)[:, None]
            out.append(0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t ** 2
                              + (-p0 + 3 * p1 - 3 * p2 + p3) * t ** 3))
        out.append(p[-2][None, :])
        return np.vstack(out)

    def _resample(self, pts):
        pts = np.asarray(pts, dtype=np.float64)
        seg = np.hypot(*np.diff(pts, axis=0).T)
        total = seg.sum()
        if total < 1e-6:
            return pts
        n = max(int(total / self.step), 3)
        cum = np.concatenate([[0], np.cumsum(seg)])
        q = np.linspace(0, total, n)
        return np.stack([np.interp(q, cum, pts[:, 0]), np.interp(q, cum, pts[:, 1])], axis=1)

    def _jitter(self, n, span=11):
        v = self.rng.standard_normal(n + span * 2)
        k = np.hanning(span * 2 + 1)
        k = k / np.sqrt((k * k).sum())
        return np.convolve(v, k, mode="same")[span:span + n]

    def stroke(self, pts, closed=False, smooth=True, w=None, color=None, wob=None):
        ctx = self.ctx
        w = self.w if w is None else w
        wob = self.wob if wob is None else wob
        ctx.set_source_rgba(*(color or self.color), 1) if len(color or self.color) == 3 else ctx.set_source_rgba(*(color or self.color))
        dense = self._catmull(pts, closed) if smooth and len(pts) > 2 else np.asarray(pts, dtype=np.float64)
        if closed and not (smooth and len(pts) > 2):
            dense = np.vstack([dense, dense[0]])
        dense = self._resample(dense)
        n = len(dense)
        jx, jy = self._jitter(n) * wob, self._jitter(n) * wob
        if closed:
            ramp = smoothstep(0, 1, np.minimum(np.arange(n), n - 1 - np.arange(n)) / max(n * 0.1, 1))
            jx, jy = jx * ramp, jy * ramp
        dense = dense + np.stack([jx, jy], axis=1)
        ww = w * (1 + 0.14 * np.tanh(self._jitter(n, 18)))
        for i in range(n - 1):
            ctx.set_line_width(max(ww[i], 0.2))
            ctx.move_to(*dense[i])
            ctx.line_to(*dense[i + 1])
            ctx.stroke()
        return dense

    def fill(self, pts, color, smooth=False, wob=None, closed=True):
        ctx = self.ctx
        wob = self.wob if wob is None else wob
        dense = self._catmull(pts, True) if smooth else np.vstack([pts, pts[0]])
        dense = self._resample(dense)
        n = len(dense)
        ramp = smoothstep(0, 1, np.minimum(np.arange(n), n - 1 - np.arange(n)) / max(n * 0.1, 1))
        dense = dense + np.stack([self._jitter(n) * wob * ramp, self._jitter(n) * wob * ramp], axis=1)
        ctx.move_to(*dense[0])
        for p in dense[1:]:
            ctx.line_to(*p)
        ctx.close_path()
        ctx.set_source_rgba(*color) if len(color) == 4 else ctx.set_source_rgb(*color)
        ctx.fill()

    def circle_pts(self, cx, cy, r, ry=None, a0=0.0, a1=360.0, n=None):
        ry = r if ry is None else ry
        n = n or max(int((a1 - a0) / 18), 8)
        return [(cx + r * math.cos(math.radians(a)), cy + ry * math.sin(math.radians(a)))
                for a in np.linspace(a0, a1, n)]

    def circle(self, cx, cy, r, ry=None, **kw):
        pts = self.circle_pts(cx, cy, r, ry)[:-1]
        return self.stroke(pts, closed=True, **kw)

    def arc(self, cx, cy, r, a0, a1, **kw):
        return self.stroke(self.circle_pts(cx, cy, r, None, a0, a1), **kw)

    def line(self, a, b, **kw):
        return self.stroke([a, b], smooth=False, **kw)

    def rrect_pts(self, x, y, w, h, r):
        pts = []
        for cx, cy, a0 in ((x + w - r, y + r, -90), (x + w - r, y + h - r, 0), (x + r, y + h - r, 90), (x + r, y + r, 180)):
            pts += [(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a))) for a in (a0, a0 + 30, a0 + 60, a0 + 90)]
        return pts

    def rrect(self, x, y, width, height, r, **kw):
        return self.stroke(self.rrect_pts(x, y, width, height, r), closed=True, smooth=False, **kw)


def canvas(w, h):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    return surf, cairo.Context(surf)
