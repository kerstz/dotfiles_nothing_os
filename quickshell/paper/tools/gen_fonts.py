import sys
import unicodedata
from pathlib import Path

from fontTools import subset
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

UNICODES = list(range(0x20, 0x7F)) + list(range(0xA0, 0x180)) + [
    0x2013, 0x2014, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2026, 0x20AC, 0x2190, 0x2191, 0x2192, 0x2193,
]
ACCENTED = "éèêëàâäçîïôöûùüÿñÉÈÊËÀÂÄÇÎÏÔÖÛÙÜŸÑáíóúãõåÁÍÓÚ"
MARKS = {0x301: "acute", 0x300: "grave", 0x302: "circ", 0x308: "dia", 0x327: "ced", 0x303: "tilde", 0x30A: "ring"}


def latin_subset(src, dst):
    opts = subset.Options()
    opts.hinting = False
    opts.layout_features = ["*"]
    opts.name_IDs = ["*"]
    opts.notdef_outline = True
    font = TTFont(src)
    s = subset.Subsetter(opts)
    s.populate(unicodes=UNICODES)
    s.subset(font)
    font.save(dst)


def poly(pen, pts):
    pen.moveTo(pts[0])
    for p in pts[1:]:
        pen.lineTo(p)
    pen.closePath()


def stroke_rect(pen, a, b, w):
    dx, dy = b[0] - a[0], b[1] - a[1]
    n = (dx * dx + dy * dy) ** 0.5 or 1
    ox, oy = -dy / n * w / 2, dx / n * w / 2
    poly(pen, [(a[0] + ox, a[1] + oy), (a[0] - ox, a[1] - oy), (b[0] - ox, b[1] - oy), (b[0] + ox, b[1] + oy)])


def draw_mark(pen, kind, cx, top, bottom, upm, w):
    s = upm * 0.1
    y = top + upm * 0.06
    if kind == "acute":
        stroke_rect(pen, (cx - s * 0.55, y), (cx + s * 0.6, y + s * 1.25), w)
    elif kind == "grave":
        stroke_rect(pen, (cx + s * 0.55, y), (cx - s * 0.6, y + s * 1.25), w)
    elif kind == "circ":
        stroke_rect(pen, (cx - s * 0.8, y), (cx, y + s), w)
        stroke_rect(pen, (cx, y + s), (cx + s * 0.8, y), w)
    elif kind == "dia":
        for dx in (-s * 0.62, s * 0.62):
            stroke_rect(pen, (cx + dx, y + s * 0.2), (cx + dx, y + s * 0.2 + w * 1.15), w * 1.15)
    elif kind == "tilde":
        stroke_rect(pen, (cx - s, y + s * 0.2), (cx - s * 0.3, y + s * 0.75), w)
        stroke_rect(pen, (cx - s * 0.3, y + s * 0.75), (cx + s * 0.3, y + s * 0.3), w)
        stroke_rect(pen, (cx + s * 0.3, y + s * 0.3), (cx + s, y + s * 0.85), w)
    elif kind == "ring":
        for a, b in (((-1, 0), (0, 1)), ((0, 1), (1, 0)), ((1, 0), (0, -1)), ((0, -1), (-1, 0))):
            stroke_rect(pen, (cx + a[0] * s * .55, y + s * .55 + a[1] * s * .55), (cx + b[0] * s * .55, y + s * .55 + b[1] * s * .55), w * .8)
    elif kind == "ced":
        yb = bottom
        stroke_rect(pen, (cx, yb + s * 0.2), (cx + s * 0.1, yb - s * 0.5), w)
        stroke_rect(pen, (cx + s * 0.1, yb - s * 0.5), (cx - s * 0.65, yb - s * 1.0), w)


def add_glyph(font, name, code, advance, draw):
    gs = font.getGlyphSet()
    pen = TTGlyphPen(gs)
    draw(pen, gs)
    glyf = font["glyf"]
    glyf[name] = pen.glyph()
    font.setGlyphOrder(glyf.glyphOrder)
    glyf[name].recalcBounds(glyf)
    font["hmtx"].metrics[name] = (advance, getattr(glyf[name], "xMin", 0) or 0)
    for table in font["cmap"].tables:
        if table.isUnicode():
            table.cmap[code] = name


def add_accents(font):
    upm = font["head"].unitsPerEm
    cmap = font.getBestCmap()
    glyf = font["glyf"]
    hmtx = font["hmtx"]
    bar = glyf[cmap[ord("l")]]
    bar.recalcBounds(glyf)
    weight = max(min((bar.xMax - bar.xMin) * 0.9, upm * 0.075), upm * 0.04)
    for ch in ACCENTED:
        if ord(ch) in cmap:
            continue
        parts = unicodedata.normalize("NFD", ch)
        base = "ı" if parts[0] == "i" and "ı" in font.getBestCmap() else parts[0]
        base_name = cmap[ord(base)]
        kind = MARKS[ord(parts[1])]
        g = glyf[base_name]
        g.recalcBounds(glyf)
        adv = hmtx[base_name][0]
        cx = (g.xMin + g.xMax) / 2
        top, bottom = g.yMax, min(g.yMin, 0)

        def draw(pen, gs, base_name=base_name, kind=kind, cx=cx, top=top, bottom=bottom):
            gs[base_name].draw(pen)
            draw_mark(pen, kind, cx, top, bottom, upm, weight)

        add_glyph(font, f"u{ord(ch):04X}", ord(ch), adv, draw)

    period = cmap[ord(".")]
    padv = hmtx[period][0]

    def ellipsis(pen, gs):
        for i in range(3):
            gs[period].draw(TransformPen(pen, (1, 0, 0, 1, i * padv * 0.9, 0)))

    add_glyph(font, "u2026", 0x2026, int(padv * 2.8), ellipsis)

    o, e = cmap[ord("o")], cmap[ord("e")]
    oadv = hmtx[o][0]

    def oe(pen, gs):
        gs[o].draw(pen)
        gs[e].draw(TransformPen(pen, (1, 0, 0, 1, oadv * 0.8, 0)))

    add_glyph(font, "u0153", 0x153, int(oadv * 0.8 + hmtx[e][0]), oe)

    lt, gt = cmap[ord("<")], cmap[ord(">")]
    ladv = hmtx[lt][0]

    def quote(glyph):
        def inner(pen, gs):
            for i in range(2):
                gs[glyph].draw(TransformPen(pen, (0.62, 0, 0, 0.62, i * ladv * 0.42, upm * 0.1)))
        return inner

    add_glyph(font, "u00AB", 0xAB, int(ladv * 1.05), quote(lt))
    add_glyph(font, "u00BB", 0xBB, int(ladv * 1.05), quote(gt))


def rename(font, family, style):
    for rec in font["name"].names:
        if rec.nameID in (1, 16):
            rec.string = family
        elif rec.nameID in (2, 17):
            rec.string = style
        elif rec.nameID == 4:
            rec.string = f"{family} {style}"
        elif rec.nameID == 6:
            rec.string = family.replace(" ", "") + "-" + style
        elif rec.nameID == 3:
            rec.string = f"{family} {style} (derived from Gaegu)"


def monofy(src, dst, family="Paper Mono", ratio=0.46, squeeze=0.86):
    font = TTFont(src)
    upm = font["head"].unitsPerEm
    adv = int(upm * ratio)
    gs = font.getGlyphSet()
    glyf = font["glyf"]
    hmtx = font["hmtx"]
    new = {}
    for name in font.getGlyphOrder():
        width, _ = hmtx[name]
        pen = TTGlyphPen(gs)
        sx = min(squeeze, (adv * 0.94) / width) if width > adv * 0.94 else squeeze
        dx = (adv - width * sx) / 2
        gs[name].draw(TransformPen(pen, (sx, 0, 0, 1, dx, 0)))
        new[name] = pen.glyph()
    for name, glyph in new.items():
        glyf[name] = glyph
        glyph.recalcBounds(glyf)
        hmtx[name] = (adv, glyph.xMin if glyph.numberOfContours else 0)
    for tag in ("GPOS", "GSUB", "GDEF", "kern"):
        if tag in font:
            del font[tag]
    font["post"].isFixedPitch = 1
    font["OS/2"].panose.bProportion = 9
    font["OS/2"].xAvgCharWidth = adv
    font["hhea"].advanceWidthMax = adv
    rename(font, family, "Regular")
    font.save(dst)


def main():
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    for name in ("Gaegu-Light", "Gaegu-Regular", "Gaegu-Bold"):
        dst = out / f"{name}.ttf"
        latin_subset(src / f"{name}.ttf", dst)
        font = TTFont(dst)
        add_accents(font)
        font.save(dst)
    monofy(out / "Gaegu-Bold.ttf", out / "PaperMono-Regular.ttf")
    latin_subset(src / "ShadowsIntoLightTwo-Regular.ttf", out / "ShadowsIntoLightTwo-Regular.ttf")


main()
