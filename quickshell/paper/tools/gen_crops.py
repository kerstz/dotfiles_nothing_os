import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets"
wall = Image.open(OUT / "wallpaper.png").convert("RGB")

W, H = 368, 304
crop_w = 1180
crop_h = crop_w * H // W
left = wall.width - crop_w - 120
top = wall.height - crop_h - 240
photo = wall.crop((left, top, left + crop_w, top + crop_h)).resize((W, H), Image.LANCZOS)
mask = Image.new("L", (W, H), 0)
ImageDraw.Draw(mask).polygon([(0, 0), (W, 12), (W - 40, H), (0, H)], fill=255)
out = photo.convert("RGBA")
out.putalpha(mask.filter(ImageFilter.GaussianBlur(0.7)))
out.save(OUT / "photo.png", optimize=True)

cat = Image.open(OUT / "doodles" / "cat.png").convert("RGBA")
cover = Image.new("RGBA", (256, 256), (225, 214, 196, 255))
scale = 236 / cat.width
drawn = cat.resize((236, int(cat.height * scale)), Image.LANCZOS)
cover.alpha_composite(drawn, (10, 256 - drawn.height + 4))
cover.convert("RGB").save(OUT / "cover.png", optimize=True)
