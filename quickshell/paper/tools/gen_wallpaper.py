import math
import sys
from pathlib import Path

import cairo
import numpy as np
from PIL import Image, ImageFilter

from paperlib import fractal, smoothstep

W, H = 3440, 1440
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "wallpaper.png"
rng = np.random.default_rng(2026)


def hexc(s):
    return np.array([int(s[i:i + 2], 16) for i in (1, 3, 5)], dtype=np.float32)


def ramp(t, stops):
    t = np.clip(t, 0, 1)
    xs = [s[0] for s in stops]
    cs = np.array([hexc(s[1]) for s in stops])
    return np.stack([np.interp(t, xs, cs[:, i]) for i in range(3)], axis=-1).astype(np.float32)


def warp(field, amount, seed_a, seed_b):
    h, w = field.shape
    r = np.random.default_rng(seed_a)
    dx = fractal((h, w), 1.6, r) * amount
    dy = fractal((h, w), 1.6, np.random.default_rng(seed_b)) * amount
    y, x = np.mgrid[0:h, 0:w]
    xi = np.round(x + dx).astype(np.int32) % w
    yi = np.round(y + dy).astype(np.int32) % h
    return field[yi, xi]


def ridge(seed, base, amp, slope=None, beta=1.7):
    r = np.random.default_rng(seed)
    n = fractal((2, W), beta, r)[0]
    y = base + n * amp
    if slope is not None:
        y = y + slope
    return y


def ridge_line(x):
    xv = (x / W - 0.37) / 0.63
    rise = 0.31 + 0.33 * np.clip(xv / 0.72, 0, 1)
    return np.where(xv < 0, 0.31 + xv * 0.10, rise)


def sky():
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    u = y / H
    glow = np.exp(-(((x / W - 0.86) / 0.6) ** 2)) * 0.12 + np.exp(-(((x / W - 0.1) / 0.3) ** 2)) * 0.05
    lean = 0.62 - ridge_line(x)
    t = u + lean + glow * smoothstep(0.1, 0.5, u) * 0.3 + fractal((H, W), 1.8, rng, aniso=(1.0, 0.5)) * 0.012
    base = ramp(t, [
        (0.0, "#2f5a8c"), (0.1, "#386899"), (0.2, "#4c7daa"), (0.3, "#7f9ac0"), (0.38, "#b69db5"),
        (0.44, "#dc9c95"), (0.5, "#ee9f77"), (0.56, "#f0ad7d"), (0.64, "#d68b78"), (1.0, "#a06b6b"),
    ])
    n1 = warp(fractal((H, W), 1.55, rng, aniso=(0.55, 1.5)), 26, 1, 2)
    n2 = warp(fractal((H, W), 1.1, rng, aniso=(0.42, 2.2)), 12, 3, 4)
    density = smoothstep(0.15, 1.45, n1 + n2 * 0.32)
    lit = smoothstep(-0.2, 1.1, n1 * 0.55 + n2 * 0.7 + (0.5 - u) * 0.9)
    u = np.clip(u + lean, 0, 1)
    cloud = ramp(u * 1.45, [(0.0, "#28557f"), (0.3, "#4a7099"), (0.5, "#6f83ad"), (0.62, "#b57e8d"), (0.8, "#c97974"), (1.0, "#8f5f64")])
    bright = ramp(u * 1.45, [(0.0, "#7fa2c8"), (0.14, "#9db8d6"), (0.3, "#c9d4e2"), (0.48, "#e9c7c5"), (0.62, "#f7c49a"), (0.8, "#f2a780"), (1.0, "#d07f6b")])
    tint = cloud * (1 - lit[..., None]) + bright * lit[..., None]
    dens = density * (0.45 + 0.55 * smoothstep(0.04, 0.3, u))
    img = base * (1 - dens[..., None] * 0.92) + tint * dens[..., None] * 0.92
    high = smoothstep(1.35, 2.3, warp(fractal((H, W), 1.45, rng, aniso=(0.6, 1.4)), 20, 5, 6)) * (1 - smoothstep(0.1, 0.42, u))
    img = img * (1 - high[..., None] * 0.65) + hexc("#e7eef2")[None, None, :] * high[..., None] * 0.65
    return img


def layer(img, ridge_y, color_top, color_bot, tex_amp, seed, depth=320, tex_aniso=(0.7, 1.4)):
    h, w = img.shape[:2]
    y = np.arange(h, dtype=np.float32)[:, None]
    mask = smoothstep(-1.2, 1.2, y - ridge_y[None, :])
    r = np.random.default_rng(seed)
    tex = warp(fractal((h, w), 1.0, r, aniso=tex_aniso), 14, seed + 1, seed + 2)
    tex2 = fractal((h, w), 0.6, r, aniso=(0.6, 1.6))
    d = np.clip((y - ridge_y[None, :]) / depth, 0, 1)
    col = hexc(color_top)[None, None, :] * (1 - d[..., None]) + hexc(color_bot)[None, None, :] * d[..., None]
    shade = (tex * 0.75 + tex2 * 0.45)[..., None] * tex_amp
    col = col + shade * np.array([0.8, 1.0, 1.15], dtype=np.float32)
    return img * (1 - mask[..., None]) + col * mask[..., None]


def foliage(img, ridge_y, seed, colors, light, density=0.62):
    h, w = img.shape[:2]
    r = np.random.default_rng(seed)
    y = np.arange(h, dtype=np.float32)[:, None]
    blob = warp(fractal((h, w), 1.15, r), 26, seed + 1, seed + 2)
    fine = warp(fractal((h, w), 0.7, r), 10, seed + 3, seed + 4)
    edge = ridge_y[None, :] + blob * 34 + fine * 10
    mask = smoothstep(-1.5, 1.5, y - edge)
    n = blob * 0.65 + fine * 0.55
    col = ramp((n + 2.0) / 4.0, [(s, c) for s, c in colors])
    lit = smoothstep(density * 1.65, density * 2.7, fine * 0.92 + blob * 0.42)
    grad = np.clip((y - ridge_y[None, :]) / 240, 0, 1)
    lit = lit * (0.75 + 0.4 * (1 - grad))
    col = col * (1 - lit[..., None]) + hexc(light)[None, None, :] * lit[..., None]
    return img * (1 - mask[..., None]) + col * mask[..., None]


def poles(arr):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, W, H)
    ctx = cairo.Context(surf)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    dark = (0.09, 0.105, 0.135)

    def pole(x, top, base, w, arm, arms=3):
        grad = cairo.LinearGradient(x - w / 2, 0, x + w / 2, 0)
        grad.add_color_stop_rgb(0, 0.05, 0.06, 0.08)
        grad.add_color_stop_rgb(0.7, 0.13, 0.13, 0.16)
        grad.add_color_stop_rgb(1, 0.26, 0.2, 0.2)
        ctx.set_source(grad)
        ctx.move_to(x - w * 0.42, top)
        ctx.line_to(x + w * 0.42, top)
        ctx.line_to(x + w * 0.56, base)
        ctx.line_to(x - w * 0.56, base)
        ctx.close_path()
        ctx.fill()
        ctx.set_source_rgb(*dark)
        for i in range(arms):
            y = top + arm * 0.13 + i * arm * 0.19
            half = arm * (0.55 if i else 0.72)
            ctx.set_line_width(w * 0.42)
            ctx.move_to(x - half, y + 2)
            ctx.line_to(x + half, y - 2)
            ctx.stroke()
            for k in (-0.9, -0.4, 0.42, 0.9):
                ctx.set_line_width(w * 0.3)
                ctx.move_to(x + k * half, y - w * 0.55)
                ctx.line_to(x + k * half, y + w * 0.1)
                ctx.stroke()
        ctx.set_line_width(w * 0.34)
        ctx.move_to(x - arm * 0.2, top + arm * 0.62)
        ctx.line_to(x, top + arm * 0.88)
        ctx.line_to(x + arm * 0.2, top + arm * 0.62)
        ctx.stroke()
        for off in (0.5, 0.82):
            ctx.rectangle(x - w * 1.0, top + arm * 1.1 + arm * off, w * 2.0, w * 1.6)
            ctx.fill()

    def wire(x0, y0, x1, y1, sag, width=1.6):
        ctx.set_source_rgba(*dark, 0.92)
        ctx.set_line_width(width)
        ctx.move_to(x0, y0)
        ctx.curve_to(x0 + (x1 - x0) * 0.33, y0 + sag, x0 + (x1 - x0) * 0.66, y1 + sag, x1, y1)
        ctx.stroke()

    p1 = (2920, 890, 1440, 11, 92)
    p2 = (1150, 1160, 1440, 13, 84)
    p3 = (120, 1020, 1440, 14, 96)
    pole(*p1)
    pole(*p2)
    pole(*p3)
    for i, dy in enumerate((22, 54, 90)):
        for k in (-1, 1):
            wire(p1[0] + k * 64, p1[1] + dy * 0.6, p2[0] + k * 46, p2[1] + dy * 0.45, 62 + i * 8)
            wire(p2[0] + k * 46, p2[1] + dy * 0.45, p3[0] + k * 52, p3[1] + dy * 0.55, 76 + i * 8)
            wire(p1[0] + k * 64, p1[1] + dy * 0.6, W + 120, p1[1] + 110 + dy, 40 + i * 8)
    surf.flush()
    data = np.ndarray((H, W, 4), dtype=np.uint8, buffer=surf.get_data()).astype(np.float32)
    a = data[..., 3:4] / 255
    col = data[..., [2, 1, 0]]
    return arr * (1 - a) + col


def main():
    img = sky()
    x = np.arange(W, dtype=np.float32)
    far = ridge(11, 980, 46) - 40 * np.sin(x / W * 7)
    img = layer(img, far, "#4d5f8a", "#2f4f78", 6.0, 21, depth=240)
    mid = ridge(12, 1050, 60, beta=1.55)
    img = layer(img, mid, "#223f60", "#152c44", 8.5, 31, depth=260)
    xv = (x / W - 0.37) / 0.63
    hill = ridge(13, 0, 24, slope=ridge_line(x) * H + 6 + np.clip(xv - 0.72, 0, None) * H * 1.7, beta=1.25)
    img = layer(img, hill, "#1c3550", "#112232", 9.0, 41, depth=420, tex_aniso=(0.5, 1.8))
    near = ridge(14, 1205, 62, beta=1.45)
    img = foliage(img, near, 51, [(0.0, "#101c22"), (0.45, "#1b2f36"), (0.8, "#2c4a4c"), (1.0, "#3f6157")], "#6f6a3e", density=0.92)
    close = ridge(15, 1345, 42, beta=1.4)
    img = foliage(img, close, 61, [(0.0, "#0c151a"), (0.5, "#16262c"), (0.85, "#25403f"), (1.0, "#3a5848")], "#8a7a3e", density=0.78)

    out = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB")
    small = out.resize((W // 2, H // 2), Image.LANCZOS).filter(ImageFilter.ModeFilter(5)).filter(ImageFilter.MedianFilter(3))
    painted = small.resize((W, H), Image.BICUBIC).filter(ImageFilter.UnsharpMask(radius=3, percent=70, threshold=2))
    grain = fractal((H, W), 0.3, np.random.default_rng(99)) * 1.6
    arr = poles(np.asarray(painted, dtype=np.float32)) + grain[..., None]
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB").save(OUT, optimize=True)


main()
