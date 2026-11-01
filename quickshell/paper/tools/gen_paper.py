import sys
from pathlib import Path

import numpy as np
from PIL import Image

from paperlib import PAPER, compose_sheet, fold_corner, make_tape

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "paper"
OUT.mkdir(parents=True, exist_ok=True)

SLICE = 104
SIZE = 1024
PERIOD = SIZE - 2 * SLICE
M = 28


def save(img, name):
    arr = np.asarray(img).copy()
    arr[..., :3] = (arr[..., :3] // 2) * 2
    Image.fromarray(arr, "RGBA").save(OUT / name, optimize=True, compress_level=9)


def sheets():
    for i, (seed, amp) in enumerate(((11, 2.6), (29, 3.0), (47, 2.3))):
        save(compose_sheet(SIZE, SIZE, seed, margin=M, amp=amp, radius=11, period=PERIOD, oy=SLICE, ox=SLICE), f"sheet_{i}.png")


def cards():
    specs = {
        "clock": (346, 216, 101, 3.2, "tr"),
        "quote": (336, 228, 102, 2.8, None),
        "todo": (334, 290, 103, 2.6, None),
        "music": (344, 272, 104, 2.6, "tr"),
        "photo": (348, 190, 105, 3.0, None),
        "note": (300, 340, 106, 2.6, None),
    }
    for name, (w, h, seed, amp, fold) in specs.items():
        img = compose_sheet(h + 2 * M, w + 2 * M, seed, margin=M, amp=amp, radius=9)
        if fold:
            img = fold_corner(img, fold, size=15, margin=M + 3)
        save(img, f"card_{name}.png")
    save(compose_sheet(150 + M, 960 + 2 * M, 107, margin=M, amp=2.8, radius=18, cut="b"), "dock.png")


def tapes():
    make_tape(OUT / "tape_tan.png", 180, 66, (205, 178, 146), 201, 0.82)
    make_tape(OUT / "tape_blue.png", 360, 44, (156, 182, 224), 202, 0.86)
    make_tape(OUT / "tape_pink.png", 150, 54, (233, 166, 154), 203, 0.88)
    make_tape(OUT / "tape_gray.png", 220, 260, (178, 174, 164), 204, 0.46)


sheets()
cards()
tapes()
