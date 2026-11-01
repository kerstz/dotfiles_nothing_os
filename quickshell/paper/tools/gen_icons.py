import math
import zlib
import sys
from pathlib import Path

import cairo
import numpy as np

from paperlib import INK, INK_SOFT, Pen, canvas

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "icons"
OUT.mkdir(parents=True, exist_ok=True)

BLUE = (0.635, 0.752, 0.890)
BLUE_DEEP = (0.545, 0.682, 0.847)
BLUE_LINE = (0.17, 0.25, 0.36)
CORAL = (0.915, 0.522, 0.470)


def icon(name, draw, size=128, grid=24.0, w=1.2, wob=0.05, color=INK):
    surf, ctx = canvas(size, size)
    ctx.scale(size / grid, size / grid)
    pen = Pen(ctx, color=color, w=w, wob=wob, seed=zlib.crc32(name.encode()) % 9973, step=0.25)
    draw(pen)
    surf.write_to_png(str(OUT / f"{name}.png"))


def wifi(p):
    for r, lw in ((3.6, 1.7), (7.2, 1.7), (10.8, 1.7)):
        p.arc(12, 19, r, -138, -42, w=lw)
    p.fill(p.circle_pts(12, 19, 1.3)[:-1], INK)


def bluetooth(p):
    p.stroke([(7, 7.4), (17, 16.6), (12, 21.4), (12, 2.6), (17, 7.4), (7, 16.6)], smooth=False, w=1.25)


def volume(p):
    p.stroke([(3.2, 9.3), (7, 9.3), (11.8, 5.2), (11.8, 18.8), (7, 14.7), (3.2, 14.7)], closed=True, smooth=False)
    p.arc(12.4, 12, 3.8, -48, 48)
    p.arc(12.4, 12, 7.2, -50, 50)


def volume_mute(p):
    p.stroke([(3.2, 9.3), (7, 9.3), (11.8, 5.2), (11.8, 18.8), (7, 14.7), (3.2, 14.7)], closed=True, smooth=False)
    p.line((15.2, 9.5), (20.5, 14.8))
    p.line((20.5, 9.5), (15.2, 14.8))


def battery(p):
    p.rrect(2, 6, 18, 12, 2.2)
    p.line((22, 10), (22, 14), w=1.45)


def terminal_small(p):
    p.rrect(3, 3, 18, 18, 3.2)
    p.line((8, 3), (8, 1.8), w=1.2)
    p.stroke([(8.4, 8.5), (12, 12), (8.4, 15.5)], smooth=False)
    p.line((13, 16), (16.5, 16))


def terminal(p):
    p.rrect(1.8, 3.4, 20.4, 17.2, 2.6)
    p.stroke([(5.8, 8), (10, 12), (5.8, 16)], smooth=False)
    p.line((11.8, 16.4), (16.5, 16.4))


def folder_open(p):
    p.fill([(2.5, 19.6), (5.2, 10.8), (21.8, 10.8), (19.8, 19.6)], (0.94, 0.915, 0.87, 1))
    for x, y, r, c in ((14.4, 14.9, 1.5, BLUE_DEEP), (16.8, 15.8, 1.6, (0.44, 0.61, 0.83)), (15.6, 17.4, 1.3, BLUE), (12.4, 17.2, 1.0, BLUE)):
        p.fill(p.circle_pts(x, y, r)[:-1], c)
    p.stroke([(2.6, 18.8), (2.6, 5.8), (3.6, 4.6), (8.8, 4.6), (10.8, 7), (19.4, 7), (20.3, 8), (20.3, 10.6)], smooth=False)
    p.stroke([(2.6, 19.7), (5.2, 10.8), (22.2, 10.8), (19.8, 19.7)], closed=True, smooth=False)


def globe(p):
    p.circle(12, 12, 10)
    p.stroke(p.circle_pts(12, 12, 4.6, 10)[:-1], closed=True, w=1.25)
    p.line((12, 2), (12, 22), w=1.25)
    p.line((2, 12), (22, 12), w=1.25)
    p.stroke([(3.3, 7), (12, 8.3), (20.7, 7)], w=1.25)
    p.stroke([(3.3, 17), (12, 15.7), (20.7, 17)], w=1.25)


def vscode(p):
    light, mid, deep = (0.20, 0.60, 0.88), (0.11, 0.49, 0.78), (0.07, 0.40, 0.68)
    p.fill([(17.3, 1.8), (7.3, 11.2), (3.4, 8.1), (1.7, 9.1), (5.3, 12), (1.7, 14.9), (3.4, 15.9), (7.3, 12.8), (17.3, 22.2), (17.3, 16.4), (10.5, 12), (17.3, 7.6)], mid, wob=0.02)
    p.fill([(17.3, 1.8), (7.3, 11.2), (3.4, 8.1), (1.7, 9.1), (5.3, 12), (10.5, 12), (17.3, 7.6)], light, wob=0.02)
    p.fill([(17.3, 1.8), (22.3, 4.3), (22.3, 19.7), (17.3, 22.2)], deep, wob=0.02)


def spotify(p):
    p.fill(p.circle_pts(12, 12, 10.6, n=40)[:-1], (0.34, 0.70, 0.35), smooth=True, wob=0.03)
    dark = (0.09, 0.17, 0.10)
    p.stroke([(5.6, 9.2), (12, 7.9), (18.6, 9.9)], w=1.6, color=dark)
    p.stroke([(6.4, 12.5), (12, 11.4), (17.5, 13)], w=1.4, color=dark)
    p.stroke([(7.2, 15.6), (12, 14.8), (16.5, 16)], w=1.2, color=dark)


def image(p):
    p.rrect(2, 3.6, 20, 16.8, 2.2)
    p.stroke([(2.4, 18.2), (8.4, 11), (12.4, 15.2), (15, 12.4), (21.6, 18.4)], smooth=False)
    p.circle(16.8, 7.8, 1.25, w=1.2)


def gear(p):
    pts = []
    for i in range(8):
        a = i * 45
        for da, r in ((-15, 7.6), (-9, 10.3), (9, 10.3), (15, 7.6)):
            pts.append((12 + r * math.cos(math.radians(a + da)), 12 + r * math.sin(math.radians(a + da))))
    p.stroke(pts, closed=True, smooth=False)
    p.circle(12, 12, 3.6)


def trash(p):
    p.line((3.2, 6.2), (20.8, 6.2))
    p.stroke([(8.6, 6), (9.2, 3.2), (14.8, 3.2), (15.4, 6)], smooth=False)
    p.stroke([(5, 6.4), (6.2, 21.2), (17.8, 21.2), (19, 6.4)], smooth=False)
    for x in (9.4, 12, 14.6):
        p.line((x, 9.2), (x, 18.2), w=1.3)


def home(p):
    p.stroke([(2.4, 12), (12, 3.2), (21.6, 12)], smooth=False)
    p.stroke([(5, 10), (5, 20.6), (9.6, 20.6), (9.6, 14.2), (14.4, 14.2), (14.4, 20.6), (19, 20.6), (19, 10)], smooth=False)


def desktop(p):
    p.rrect(2.6, 4, 18.8, 14, 2)
    p.line((3, 15), (21, 15), w=1.2)
    p.line((10, 20.4), (14, 20.4), w=1.25)
    p.line((12, 18), (12, 20.2), w=1.4)


def document(p):
    p.stroke([(5, 2.8), (14.6, 2.8), (19.4, 7.6), (19.4, 21.2), (5, 21.2)], closed=True, smooth=False)
    p.stroke([(14.4, 3), (14.4, 7.8), (19.2, 7.8)], smooth=False, w=1.3)
    p.line((8.4, 12), (15.8, 12), w=1.25)
    p.line((8.4, 15), (15.8, 15), w=1.25)
    p.line((8.4, 18), (13, 18), w=1.25)


def download(p):
    p.line((12, 2.8), (12, 16))
    p.stroke([(6.6, 11), (12, 16.4), (17.4, 11)], smooth=False)
    p.line((3.6, 20.6), (20.4, 20.6))


def pictures(p):
    p.rrect(2.4, 3.8, 19.2, 16.4, 2.2)
    p.stroke([(3, 16.6), (8.2, 10.6), (12, 14.4), (14.8, 11.6), (21, 17)], smooth=False, w=1.35)
    p.circle(16.4, 7.8, 1.2, w=1.1)


def music(p):
    p.circle(6.4, 18.2, 2.6)
    p.circle(17, 16.2, 2.6)
    p.line((9, 18), (9, 5.6))
    p.line((19.6, 16), (19.6, 3.2))
    p.line((9, 5.6), (19.6, 3.2))
    p.line((9, 9), (19.6, 6.6))


def video(p):
    p.rrect(2.4, 4.2, 19.2, 15.6, 2.6)
    p.stroke([(10, 9), (15.6, 12), (10, 15)], closed=True, smooth=False, w=1.3)
    p.line((5, 4.6), (5, 2.8), w=1.1)


def folder(p):
    p.stroke([(2.6, 19.4), (2.6, 6), (3.6, 4.8), (9, 4.8), (11, 7.2), (20.4, 7.2), (21.4, 8.2), (21.4, 19.4)], closed=True, smooth=False)
    p.line((2.8, 10), (21.2, 10), w=1.2)


def search(p):
    p.circle(10.4, 10.4, 7)
    p.line((15.6, 15.6), (21.4, 21.4), w=1.45)


def sort(p):
    p.line((2.6, 10), (20.4, 8.4), w=1.25)
    p.stroke([(15.8, 5.2), (21, 8.2), (16.2, 11.6)], smooth=False, w=1.25)
    p.line((14.6, 3.4), (10.4, 17.4), w=1.25)
    p.fill(p.circle_pts(11, 20.6, 0.9)[:-1], INK)


def dots(p):
    for x in (4.4, 12, 19.6):
        p.fill(p.circle_pts(x, 12, 2.2)[:-1], INK, wob=0.02)


def close(p):
    p.line((4, 4), (20, 20), w=1.6)
    p.line((20, 4), (4, 20), w=1.6)


def back(p):
    p.line((21, 12), (3.4, 12), w=1.5)
    p.stroke([(10, 5.4), (3.2, 12), (10, 18.6)], smooth=False, w=1.5)


def forward(p):
    p.line((3, 12), (20.6, 12), w=1.5)
    p.stroke([(14, 5.4), (20.8, 12), (14, 18.6)], smooth=False, w=1.5)


def reload(p):
    p.arc(12, 12.6, 8.4, -62, 245, w=1.25)
    p.stroke([(16, 1.6), (16.6, 5.6), (12.6, 6.6)], smooth=False, w=1.25)


def menu(p):
    for y in (5.4, 12, 18.6):
        p.line((3, y), (21, y), w=1.25)


def plus(p):
    p.line((12, 3.4), (12, 20.6), w=1.25)
    p.line((3.4, 12), (20.6, 12), w=1.25)


def star_pts(cx=12, cy=12.6, r=10.2, ratio=0.42):
    pts = []
    for i in range(10):
        a = -90 + i * 36
        rr = r if i % 2 == 0 else r * ratio
        pts.append((cx + rr * math.cos(math.radians(a)), cy + rr * math.sin(math.radians(a))))
    return pts


def star(p):
    p.stroke(star_pts(), closed=True, smooth=False, w=1.35)


def star_red(p):
    p.fill(star_pts(r=11), CORAL, wob=0.05)


def heart_pts(cx=12, cy=12, s=1.0):
    pts = []
    for t in np.linspace(0, 2 * math.pi, 40, endpoint=False):
        x = 16 * math.sin(t) ** 3
        y = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
        pts.append((cx + x * 0.62 * s, cy + y * 0.62 * s))
    return pts


def heart(p):
    p.fill(heart_pts(), CORAL, smooth=False, wob=0.04)


def heart_line(p):
    p.stroke(heart_pts(), closed=True, smooth=False, w=1.4)


def checkbox(p):
    p.rrect(2.6, 2.6, 18.8, 18.8, 2.2, w=1.25)
    p.stroke([(6.8, 12.2), (10.6, 16.2), (17.4, 7.4)], smooth=False, w=1.45)


def prev(p):
    p.fill([(20, 4.4), (7, 12), (20, 19.6)], INK_SOFT, wob=0.05)
    p.line((4.6, 4.4), (4.6, 19.6), w=2.5, color=INK_SOFT)


def nxt(p):
    p.fill([(4, 4.4), (17, 12), (4, 19.6)], INK_SOFT, wob=0.05)
    p.line((19.4, 4.4), (19.4, 19.6), w=2.5, color=INK_SOFT)


def pause(p):
    for x in (7, 17):
        p.line((x, 4), (x, 20), w=4.6, color=INK_SOFT)


def play(p):
    p.fill([(6, 3.4), (20, 12), (6, 20.6)], INK_SOFT, wob=0.05)


def power(p):
    p.arc(12, 13, 8.6, -55, 235, w=1.45)
    p.line((12, 2.4), (12, 11.4), w=1.45)


def lock(p):
    p.rrect(4.4, 10.6, 15.2, 10.6, 2.2)
    p.arc(12, 10.4, 4.8, 180, 360)
    p.line((12, 14.4), (12, 17.4))


def logout(p):
    p.stroke([(10, 3), (4, 3), (4, 21), (10, 21)], smooth=False)
    p.line((9.4, 12), (21, 12))
    p.stroke([(16, 7), (21.2, 12), (16, 17)], smooth=False)


def restart(p):
    p.arc(12, 12.6, 8.4, -62, 245, w=1.3)
    p.stroke([(16, 1.6), (16.6, 5.6), (12.6, 6.6)], smooth=False, w=1.3)


def bell(p):
    p.stroke([(5, 17.2), (6.4, 13.6), (6.4, 9), (9, 4.8), (12, 3.8), (15, 4.8), (17.6, 9), (17.6, 13.6), (19, 17.2)])
    p.line((4.6, 17.4), (19.4, 17.4))
    p.arc(12, 19, 2.4, 10, 170)


def folder_big(glyph=None, name="folder_big"):
    size = 256
    surf, ctx = canvas(size, size)
    g = 100.0
    ctx.scale(size / g, size / g)
    p = Pen(ctx, color=BLUE_LINE, w=2.3, wob=0.1, seed=zlib.crc32(name.encode()) % 9973, step=0.6)
    body = [(6, 88), (6, 20), (8, 15), (35, 15), (42, 24), (90, 24), (94, 27), (94, 88)]
    p.fill(body, BLUE_DEEP, wob=0.1)
    p.fill([(6, 88), (6, 34), (94, 34), (94, 88)], BLUE, wob=0.08)
    grad = cairo.LinearGradient(0, 34, 0, 88)
    grad.add_color_stop_rgba(0, 1, 1, 1, 0.1)
    grad.add_color_stop_rgba(1, 0.2, 0.3, 0.5, 0.11)
    ctx.rectangle(7, 34, 86, 53)
    ctx.set_source(grad)
    ctx.fill()
    p.stroke(body, closed=True, smooth=False)
    p.line((6.6, 33.6), (93.6, 33.6), w=1.35)
    p2 = Pen(ctx, color=BLUE_LINE, w=1.75, wob=0.09, seed=7, step=0.5)
    if glyph:
        ctx.save()
        ctx.translate(50, 61)
        ctx.scale(1.85, 1.85)
        ctx.translate(-12, -12)
        p2.w = 1.0
        p2.step = 0.25
        p2.wob = 0.04
        glyph(p2)
        ctx.restore()
    surf.write_to_png(str(OUT / f"{name}.png"))


def g_desktop(p):
    p.rrect(1.6, 2.4, 20.8, 14.4, 1.6)
    p.line((12, 16.8), (12, 20.2))
    p.stroke([(7.8, 21.2), (9.8, 19.8), (14.2, 19.8), (16.2, 21.2)], closed=True, smooth=False)


def g_doc(p):
    p.stroke([(5, 1.8), (14.8, 1.8), (19.6, 6.6), (19.6, 22.2), (5, 22.2)], closed=True, smooth=False)
    p.stroke([(14.6, 2), (14.6, 6.8), (19.4, 6.8)], smooth=False)
    for y, x2 in ((11, 16), (14.2, 16), (17.4, 16), (20, 12)):
        p.line((8.2, y), (x2, y))


def g_download(p):
    p.line((12, 1.8), (12, 15.4), w=1.2)
    p.stroke([(5.6, 9.6), (12, 15.8), (18.4, 9.6)], smooth=False, w=1.2)
    p.line((3, 21), (21, 21), w=1.2)


def g_music(p):
    p.circle(5.8, 18.8, 2.9)
    p.circle(17.4, 16.4, 2.9)
    p.line((8.7, 18.6), (8.7, 4.4))
    p.line((20.3, 16.2), (20.3, 1.8))
    p.line((8.7, 4.4), (20.3, 1.8))
    p.line((8.7, 7.8), (20.3, 5.2))


def g_pictures(p):
    p.rrect(1.8, 2.6, 20.4, 18.8, 1.2)
    p.fill([(2.4, 20.6), (8.4, 11), (11.8, 15), (14.6, 12.4), (21.6, 20.6)], BLUE_LINE + (0.82,), wob=0.03)
    p.circle(16.6, 7.2, 1.6)


def g_video(p):
    p.circle(12, 12, 10)
    p.stroke([(9.4, 7.4), (16.4, 12), (9.4, 16.6)], closed=True, smooth=False)


def g_code(p):
    p.stroke([(7.4, 6.6), (1.6, 12), (7.4, 17.4)], smooth=False, w=1.3)
    p.stroke([(16.6, 6.6), (22.4, 12), (16.6, 17.4)], smooth=False, w=1.3)
    p.line((14, 3.8), (10, 20.2), w=1.3)


def g_users(p):
    p.circle(8.6, 8, 3.8)
    p.circle(16.6, 8.6, 3.2)
    p.fill([(1.4, 20.4), (2.6, 15.2), (6, 12.8), (11.4, 12.8), (14.6, 15.2), (15.8, 20.4)], BLUE_LINE + (0.85,), wob=0.03)
    p.stroke([(17, 20.4), (22.4, 20.4), (21.6, 15.6), (18.8, 13), (15.6, 13.2)], smooth=False)


def g_image(p):
    g_pictures(p)


def g_file(p):
    g_doc(p)


def file_big(name, glyph=None, tint=(0.97, 0.95, 0.91)):
    size = 256
    surf, ctx = canvas(size, size)
    ctx.scale(size / 100.0, size / 100.0)
    p = Pen(ctx, color=BLUE_LINE, w=1.9, wob=0.1, seed=zlib.crc32(name.encode()) % 9973, step=0.6)
    body = [(20, 8), (60, 8), (82, 30), (82, 92), (20, 92)]
    p.fill(body, tint, wob=0.08)
    p.stroke(body, closed=True, smooth=False)
    p.stroke([(59, 9), (59, 31), (81, 31)], smooth=False, w=1.5)
    if glyph:
        ctx.save()
        ctx.translate(51, 62)
        ctx.scale(1.25, 1.25)
        ctx.translate(-12, -12)
        p2 = Pen(ctx, color=BLUE_LINE, w=1.15, wob=0.04, seed=3, step=0.25)
        glyph(p2)
        ctx.restore()
    surf.write_to_png(str(OUT / f"{name}.png"))


def g_lines(p):
    for y, x2 in ((5, 21), (10, 21), (15, 21), (20, 13)):
        p.line((3, y), (x2, y))


def g_archive(p):
    p.rrect(2, 4, 20, 17, 1.6)
    p.line((2, 9), (22, 9))
    p.line((9.5, 13), (14.5, 13))


def favcat(p):
    pink = (0.91, 0.47, 0.44)
    p.fill([(4, 8), (3.6, 2.4), (9, 5.4), (15, 5.4), (20.4, 2.4), (20, 8), (21.4, 13), (18, 19), (12, 21), (6, 19), (2.6, 13)], (0.98, 0.84, 0.82, 1), wob=0.06)
    p.stroke([(4, 8), (3.6, 2.4), (9, 5.4), (15, 5.4), (20.4, 2.4), (20, 8), (21.4, 13), (18, 19), (12, 21), (6, 19), (2.6, 13)], closed=True, w=1.5, color=pink)
    p.fill(p.circle_pts(8.4, 12.2, 1.05)[:-1], pink)
    p.fill(p.circle_pts(15.6, 12.2, 1.05)[:-1], pink)
    p.stroke([(10.4, 15), (12, 16), (13.6, 15)], w=1.1, color=pink)


def youtube(p):
    red = (0.87, 0.26, 0.21)
    p.fill(p.rrect_pts(1.6, 4.4, 20.8, 15.2, 3.4), red, wob=0.05)
    p.fill([(9.8, 8.4), (16.2, 12), (9.8, 15.6)], (0.98, 0.93, 0.88), wob=0.03)


def github(p):
    dark = (0.13, 0.13, 0.14)
    p.fill(p.circle_pts(12, 12, 10.8, n=40)[:-1], dark, smooth=True, wob=0.02)
    cream = (0.93, 0.89, 0.81)
    p.fill([(7.4, 22.8), (7.4, 18.4), (5.6, 15.8), (5.6, 11.4), (6.2, 9.8), (5.9, 6.8), (8.8, 7.8), (12, 7.2), (15.2, 7.8), (18.1, 6.8), (17.8, 9.8), (18.4, 11.4), (18.4, 15.8), (16.6, 18.4), (16.6, 22.8)], cream, smooth=False, wob=0.02)
    p.fill(p.rrect_pts(8.6, 17.4, 6.8, 6, 2.2), dark, wob=0.01)
    p.fill([(7.6, 11.4), (16.4, 11.4), (17, 15), (13.4, 16.8), (10.6, 16.8), (7, 15)], cream, wob=0.01)
    p.stroke([(7.6, 19), (5.2, 19.5), (3.4, 17.6)], w=1.0, color=dark)


def reddit(p):
    orange = (0.94, 0.38, 0.13)
    p.fill(p.circle_pts(12, 13, 10.6, n=40)[:-1], orange, smooth=True, wob=0.02)
    cream = (0.98, 0.94, 0.88)
    p.fill(p.circle_pts(12, 14.6, 7.4, 5.2, n=30)[:-1], cream, smooth=True, wob=0.02)
    p.fill(p.circle_pts(4.8, 12.4, 2)[:-1], cream, wob=0.01)
    p.fill(p.circle_pts(19.2, 12.4, 2)[:-1], cream, wob=0.01)
    p.fill(p.circle_pts(9.2, 13.6, 1.25)[:-1], orange, wob=0.01)
    p.fill(p.circle_pts(14.8, 13.6, 1.25)[:-1], orange, wob=0.01)
    p.stroke([(8.8, 16.8), (12, 18.2), (15.2, 16.8)], w=0.95, color=orange)
    p.stroke([(12, 9.4), (13.2, 4.4), (17.2, 5)], w=1.0, color=orange)
    p.fill(p.circle_pts(17.6, 4.8, 1.7)[:-1], orange, wob=0.01)


def arch(p):
    blue = (0.13, 0.56, 0.84)
    p.fill([(12, 1.2), (22.6, 22.8), (18, 20), (12.4, 11), (6.2, 20), (1.4, 22.8)], blue, wob=0.05)
    p.fill([(12.4, 12.4), (17.6, 21), (12.2, 18.4), (6.6, 21)], (0.08, 0.42, 0.68, 0.3), wob=0.03)


def add_circle(p):
    p.fill(p.circle_pts(12, 12, 11.4, n=40)[:-1], (0.875, 0.85, 0.80), smooth=True, wob=0.02)
    p.circle(12, 12, 11.2, w=0.3, color=(0.5, 0.47, 0.42))
    p.line((12, 7), (12, 17), w=1.3)
    p.line((7, 12), (17, 12), w=1.3)


ICONS = {
    "wifi": wifi, "bluetooth": bluetooth, "volume": volume, "volume_mute": volume_mute, "battery": battery,
    "terminal_small": terminal_small, "terminal": terminal, "folder_open": folder_open, "globe": globe,
    "vscode": vscode, "spotify": spotify, "image": image, "gear": gear, "trash": trash, "home": home,
    "desktop": desktop, "document": document, "download": download, "pictures": pictures, "music": music,
    "video": video, "folder": folder, "search": search, "sort": sort, "dots": dots, "close": close,
    "back": back, "forward": forward, "reload": reload, "menu": menu, "plus": plus, "star": star,
    "star_red": star_red, "heart": heart, "heart_line": heart_line, "checkbox": checkbox, "prev": prev,
    "next": nxt, "pause": pause, "play": play, "power": power, "lock": lock, "logout": logout,
    "restart": restart, "bell": bell, "favcat": favcat, "youtube": youtube, "github": github,
    "reddit": reddit, "arch": arch, "add_circle": add_circle,
}

for key, fn in ICONS.items():
    icon(key, fn)

for key, fn in {
    "folder_big": None, "folder_desktop": g_desktop, "folder_documents": g_doc, "folder_download": g_download,
    "folder_music": g_music, "folder_pictures": g_pictures, "folder_videos": g_video, "folder_projects": g_code,
    "folder_templates": g_doc, "folder_public": g_users,
}.items():
    folder_big(fn, key)

for key, fn, tint in (
    ("file_big", g_lines, (0.97, 0.95, 0.91)), ("file_image", g_pictures, (0.86, 0.92, 0.98)),
    ("file_audio", g_music, (0.98, 0.90, 0.87)), ("file_video", g_video, (0.90, 0.88, 0.97)),
    ("file_code", g_code, (0.90, 0.95, 0.88)), ("file_archive", g_archive, (0.96, 0.91, 0.80)),
):
    file_big(key, fn, tint)
