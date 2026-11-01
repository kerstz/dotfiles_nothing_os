import math
import sys
from pathlib import Path

import numpy as np

from paperlib import INK, Pen, canvas

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "doodles"
OUT.mkdir(parents=True, exist_ok=True)

PENCIL = (0.17, 0.16, 0.15)
SUN = (0.95, 0.68, 0.24)
PINK = (0.87, 0.47, 0.45)


def doodle(name, w, h, scale, draw):
    surf, ctx = canvas(int(w * scale), int(h * scale))
    ctx.scale(scale, scale)
    draw(ctx)
    surf.write_to_png(str(OUT / f"{name}.png"))


def cat(ctx):
    p = Pen(ctx, color=PENCIL, w=0.95, wob=0.12, seed=4, step=0.4)
    p.stroke([(29.5, 25), (27, 9.5), (38.5, 19)], smooth=False)
    p.stroke([(49.5, 19), (61, 9.5), (58.5, 25)], smooth=False)
    p.stroke([(38.5, 19), (44, 18.2), (49.5, 19)])
    p.stroke([(29.5, 25), (25.5, 33), (28, 43), (36, 48), (44, 49.5), (52, 48), (60, 43), (62.5, 33), (58.5, 25)])
    p.stroke([(31, 15), (33, 18.5), (31.5, 21)], w=0.5)
    p.stroke([(57, 15), (55, 18.5), (56.5, 21)], w=0.5)
    p.fill(p.circle_pts(37, 33.5, 1.55)[:-1], INK, wob=0.02)
    p.fill(p.circle_pts(51, 33.5, 1.55)[:-1], INK, wob=0.02)
    p.fill([(42.8, 37.4), (45.2, 37.4), (44, 39)], INK, wob=0.02)
    p.stroke([(40.2, 40.4), (42.2, 41.8), (44, 39.8), (45.8, 41.8), (47.8, 40.4)], w=0.7)
    for a, b in (((27, 34), (14.5, 30.5)), ((26.2, 38), (13.5, 38.5)), ((28, 42), (16, 46.5)), ((61, 34), (73.5, 30.5)), ((61.8, 38), (74.5, 38.5)), ((60, 42), (72, 46.5))):
        p.line(a, b, w=0.55)
    p.stroke([(31, 47), (19, 50), (9, 59), (4.5, 70), (5, 80)])
    p.stroke([(57, 48), (60.5, 57), (60, 69), (57, 80)])
    p.stroke([(37.5, 50), (36.5, 62), (37.5, 74), (36.5, 80)], w=0.85)
    p.stroke([(50.5, 50), (51.5, 62), (50.5, 74), (51.5, 80)], w=0.85)
    p.stroke([(13, 72), (20, 63.5), (29, 67), (32.5, 76)], w=0.8)
    p.stroke([(61, 57), (69, 52), (75.5, 42), (77.5, 30)], w=0.85)
    heart = []
    for t in np.linspace(0, 2 * math.pi, 40, endpoint=False):
        x = 16 * math.sin(t) ** 3
        y = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
        heart.append((80 + x * 0.31, 20 + y * 0.31))
    p.fill(heart, (0.92, 0.66, 0.63), wob=0.02)
    p.stroke(heart, closed=True, smooth=False, w=0.7, color=PINK)


def leaf(ctx, sway=1.0):
    p = Pen(ctx, color=PENCIL, w=0.95, wob=0.12, seed=9, step=0.4)
    p.stroke([(14, 96), (19, 75), (24, 52), (28, 30), (30, 8)])
    leaves = [
        ((21, 70), (6, 66), (2, 54), (15, 55)),
        ((22, 66), (33, 67), (42, 56), (30, 53)),
        ((24, 50), (9, 44), (7, 31), (20, 34)),
        ((25, 46), (38, 45), (46, 33), (33, 32)),
        ((27, 31), (15, 25), (15, 13), (26, 18)),
        ((28, 28), (39, 24), (43, 13), (32, 14)),
        ((30, 10), (25, 2), (31, 0), (33, 4)),
    ]
    for a, b, c, d in leaves:
        p.stroke([a, b, c, d, a], closed=False, w=0.9)
        p.line(a, c, w=0.5)


def smile(ctx):
    p = Pen(ctx, color=PENCIL, w=1.0, wob=0.14, seed=5, step=0.4)
    p.fill(p.circle_pts(14, 8, 0.9)[:-1], PENCIL, wob=0.01)
    p.fill(p.circle_pts(24, 6.4, 0.9)[:-1], PENCIL, wob=0.01)
    p.stroke([(5, 21), (13, 26), (22, 25), (29, 19), (33, 8), (36, 4)], w=1.0)


def sun(ctx):
    p = Pen(ctx, color=SUN, w=1.25, wob=0.12, seed=6, step=0.3)
    p.circle(30, 30, 11.5, w=1.35)
    for a in range(0, 360, 45):
        r0, r1 = (16.5, 26) if a % 90 else (16.5, 28)
        p.line((30 + r0 * math.cos(math.radians(a)), 30 + r0 * math.sin(math.radians(a))),
               (30 + r1 * math.cos(math.radians(a)), 30 + r1 * math.sin(math.radians(a))), w=1.25)
    p.fill(p.circle_pts(25.8, 28, 0.9)[:-1], SUN, wob=0.01)
    p.stroke([(32, 28), (34, 26.8), (36, 28)], w=0.9)
    p.stroke([(25, 33), (29.5, 36.6), (35, 33)], w=1.0)


def building(p, x, base, w, h, cols, rows, seed):
    rng = np.random.default_rng(seed)
    p.stroke([(x, base), (x, base - h), (x + w, base - h), (x + w, base)], smooth=False, w=0.75)
    p.line((x - 1.5, base - h), (x + w + 1.5, base - h), w=0.75)
    p.line((x - 1.5, base - h - 1.8), (x + w + 1.5, base - h - 1.8), w=0.5)
    cw = w / (cols + 0.5)
    ch = h / (rows + 0.6)
    for r in range(rows):
        for c in range(cols):
            wx = x + cw * 0.5 + c * cw
            wy = base - h + ch * 0.55 + r * ch
            ww, wh = cw * 0.52, ch * 0.56
            p.stroke([(wx, wy), (wx + ww, wy), (wx + ww, wy + wh), (wx, wy + wh)], closed=True, smooth=False, w=0.55)
            if rng.random() < 0.62:
                for i in range(int(rng.integers(2, 5))):
                    t = (i + 0.5) / 4
                    p.line((wx + 0.3, wy + wh * t), (wx + ww - 0.3, wy + wh * t - 0.5), w=0.3, wob=0.03)
    for i in range(int(h * 1.2)):
        t = i / (h * 1.2)
        yy = base - h + 1 + t * (h - 2)
        p.line((x + w - 3.5, yy), (x + w - 0.4, yy - 1.5), w=0.28, wob=0.03)


def pole(p, x, top, base, arms=2, lean=0.0):
    p.line((x - lean, base), (x + lean, top), w=1.05)
    p.line((x + 1.05 - lean, base), (x + 1.05 + lean, top), w=0.5)
    for i in range(arms):
        y = top + 3 + i * 4.2
        p.line((x - 7, y + 0.5), (x + 8, y - 0.5), w=0.8)
        for dx in (-6, -2.5, 3, 6.5):
            p.line((x + dx, y - 1.2), (x + dx, y + 0.3), w=0.65)


def town(ctx):
    p = Pen(ctx, color=PENCIL, w=0.7, wob=0.09, seed=8, step=0.5)
    pole(p, 36, 8, 92, arms=2)
    pole(p, 137, 3, 96, arms=3)
    p.stroke([(29, 11), (60, 24), (100, 21), (130, 7)], w=0.34, wob=0.03)
    p.stroke([(29, 15), (58, 30), (100, 28), (130, 11)], w=0.34, wob=0.03)
    p.stroke([(44, 11), (70, 21), (100, 17), (130, 4)], w=0.34, wob=0.03)
    p.stroke([(144, 6), (150, 12), (154, 22)], w=0.34, wob=0.03)
    p.stroke([(144, 10), (149, 18), (152, 30)], w=0.34, wob=0.03)
    building(p, 12, 94, 16, 30, 2, 3, 1)
    building(p, 40, 94, 26, 46, 3, 4, 2)
    p.stroke([(46, 48), (46, 42), (58, 42), (58, 48)], smooth=False, w=0.6)
    building(p, 66, 94, 12, 24, 1, 2, 3)
    p.stroke([(78, 72), (78, 56), (88, 56), (88, 72)], smooth=False, w=0.5)
    p.line((84, 56), (84, 50), w=0.6)
    p.line((80, 51.5), (88, 51.5), w=0.5)
    building(p, 76, 94, 22, 22, 3, 2, 4)
    building(p, 100, 94, 30, 40, 4, 3, 5)
    p.stroke([(100, 54), (106, 49), (124, 49), (130, 54)], smooth=False, w=0.6)
    p.stroke([(103, 72), (128, 72)], w=0.5, smooth=False)
    building(p, 128, 94, 8, 18, 1, 2, 6)
    building(p, 141, 94, 14, 34, 2, 3, 7)
    p.stroke([(2, 96), (30, 95), (70, 96), (110, 95), (158, 96)], w=0.7)
    for x in range(4, 150, 5):
        p.line((x, 96.6), (x - 3, 99), w=0.28, wob=0.03)


doodle("cat", 90, 80, 5, cat)
doodle("leaf", 48, 100, 5, leaf)
doodle("smile", 40, 30, 6, smile)
doodle("sun", 60, 60, 5, sun)
doodle("town", 160, 100, 6, town)
