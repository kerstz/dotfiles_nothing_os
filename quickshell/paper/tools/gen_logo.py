import sys
from pathlib import Path

from paperlib import Pen, canvas

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "doodles" / "arch_plus.png"

ROWS = [
    (200, [(362, 372)], "/"), (228, [(348, 382)], "+"), (265, [(335, 393)], "+"), (285, [(340, 390)], "s"),
    (305, [(313, 413)], "+"), (328, [(318, 412)], "s"), (350, [(295, 435)], "+"), (370, [(298, 432)], "s"),
    (398, [(272, 458)], "+"), (432, [(252, 470)], "+"), (452, [(255, 475)], "s"),
    (482, [(230, 348), (362, 498)], "+"), (502, [(232, 340), (380, 495)], "s"),
    (525, [(210, 320), (398, 520)], "+"), (545, [(200, 310), (420, 520)], "s"),
    (578, [(188, 302), (422, 540)], "+"), (612, [(165, 282), (440, 548)], "+"),
    (652, [(148, 225), (490, 570)], "+"), (688, [(128, 175), (538, 590)], "+"),
    (720, [(127, 137), (578, 588)], "/"), (750, [(103, 113), (600, 608)], "/"),
]
BLUE = (0.18, 0.49, 0.78)
OX, OY = 70, 174
SCALE = 2.0 / 3.0
W, H = 366, 402

surf, ctx = canvas(W, H)
pen = Pen(ctx, color=BLUE, w=2.3, wob=0.28, seed=12, step=1.0)


def mark(x, y, s, w):
    pen.line((x - s, y + 0.3), (x + s, y - 0.3), w=w)
    pen.line((x, y - s * 1.05), (x, y + s * 1.05), w=w)


for row_y, spans, kind in ROWS:
    y = (row_y - OY) * SCALE
    for x0, x1 in spans:
        a = (x0 - OX) * SCALE
        b = (x1 - OX) * SCALE
        if kind == "/":
            pen.line((a, y + 5), (b, y - 5), w=2.0)
            continue
        step = 12.6
        n = max(1, round((b - a) / step))
        for i in range(n + 1):
            x = a + (b - a) * (i / n)
            if kind == "s":
                mark(x, y, 3.0, 1.9)
            else:
                mark(x, y, 4.8, 2.2)

Pen(ctx, color=(0.54, 0.52, 0.49), w=1.6, wob=0.15, seed=3, step=2.0).line((5, 6), (5, 138))
surf.write_to_png(str(OUT))
