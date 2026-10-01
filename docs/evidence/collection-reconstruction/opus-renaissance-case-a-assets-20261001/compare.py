"""Side-by-side sheets: native film crops and official photographs beside the CPU renders. Review by eye only.

python3 compare.py [root image-work/collection-room-remodel/trial folder, for the existing Muse frames sheet]
Film tiles are unchanged crops of the decoded frames in frames/. Official tiles are the byte copies in textures/.
The Glasgow library copy of the emblem book is not shown or used anywhere.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).parent
PHOTO = {"cleric": "portrait-cleric-45042-zoom-0.jpg", "woman0": "portrait-woman-34861-zoom-0.jpg", "woman1": "portrait-woman-34861-zoom-1.jpg",
    "diptych0": "diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-0.jpg", "diptych1": "diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-1.jpg",
    "cover0": "book-cover-34016-zoom-0.jpg", "cover1": "book-cover-34016-zoom-1.jpg", "jar0": "drug-jar-albarello-35713-zoom-0.jpg", "jar1": "drug-jar-albarello-35713-zoom-1.jpg"}


def film(seconds, box=None):
    image = Image.open(HERE / ("frames/IMG_6383-0%s.png" % seconds)).convert("RGB")
    return (image.crop(box) if box else image), "film IMG_6383 %ss" % seconds


def official(key, number):
    return Image.open(HERE / "textures" / PHOTO[key]).convert("RGB"), "official photograph %d" % number


def render(name, crop=None):
    image = Image.open(HERE / "renders" / (name + ".png")).convert("RGB")
    return (image.crop(crop) if crop else image), "render " + name


def sheet(name, tiles, height=560):
    scaled = [(im.resize((max(1, round(im.width * height / im.height)), height), Image.LANCZOS), text) for im, text in tiles]
    out = Image.new("RGB", (sum(im.width for im, _ in scaled) + 8 * (len(scaled) - 1), height + 22), "white")
    draw = ImageDraw.Draw(out)
    x = 0
    for im, text in scaled:
        out.paste(im, (x, 22))
        draw.text((x + 3, 5), text, fill="black")
        x += im.width + 8
    out.save(HERE / (name + ".jpg"), quality=88)
    print(name, out.size)


sheet("compare-case", [film("41.20", (0, 470, 1080, 1620)), render("grouped-left-above"), render("grouped-front"), render("grouped-flat-left-above")])
sheet("compare-close", [film("49.80", (0, 520, 1080, 1800)), render("grouped-close-left"), film("46.40", (0, 0, 1080, 1400)), render("grouped-close-right")])
sheet("compare-top-low", [render("grouped-top"), render("grouped-low-quarter"), film("41.10", (0, 470, 1080, 1620))])
sheet("compare-cleric", [film("49.80", (300, 550, 800, 1150)), official("cleric", 0), render("cleric-front"), render("cleric-quarter"), render("cleric-above"), render("cleric-rear")])
sheet("compare-woman", [film("46.40", (0, 0, 700, 800)), film("41.20", (680, 665, 985, 1060)), official("woman0", 0), official("woman1", 1),
    render("woman-front"), render("woman-quarter"), render("woman-rear")])
sheet("compare-diptych", [film("49.80", (0, 1220, 640, 1760)), official("diptych0", 0), official("diptych1", 1), render("diptych-front"), render("diptych-quarter"), render("diptych-rear")])
sheet("compare-bookcover", [film("49.80", (640, 1130, 1000, 1700)), film("41.20", (560, 990, 760, 1320)), official("cover0", 0), official("cover1", 1),
    render("bookcover-front"), render("bookcover-quarter"), render("bookcover-above"), render("bookcover-rear")])
sheet("compare-emblem", [film("46.40", (0, 850, 500, 1290)), film("41.20", (700, 1040, 1010, 1300)), render("emblem-front"), render("emblem-quarter"), render("emblem-above"), render("emblem-rear")])
sheet("compare-albarello", [film("46.40", (520, 780, 900, 1300)), film("41.20", (960, 990, 1080, 1280)), official("jar0", 0), official("jar1", 1),
    render("albarello-front"), render("albarello-quarter"), render("albarello-above"), render("albarello-rear")])
# The cleric's painting as the film sees it through the frame, straightened, beside the official photograph:
# hair, eyes, chin and hands fall at the same heights, so the photograph is the whole panel and the opening shows all of it.
from prepare_textures import CLERIC_FRAME, straighten
sheet("compare-cleric-registration", [(straighten(Image.open(HERE / "frames/IMG_6383-049.80.png").convert("RGB"), CLERIC_FRAME["sight"], (438, 666)),
    "film 49.80s, sight opening straightened"), official("cleric", 0)])
reference = lambda name: (Image.open(HERE / "muse-reference" / (name + ".png")).convert("RGB"), name)
sheet("compare-frame-references", [reference("cleric-frame-native-49.80"), reference("cleric-frame-native-41.20"), reference("cleric-frame-native-49.80-straightened"),
    reference("woman-frame-native-46.40"), reference("woman-frame-native-41.20"), official("woman0", 0)])
if len(sys.argv) > 1:
    frames = sorted(Path(sys.argv[1]).glob("*-frame*original.webp"))
    sheet("existing-muse-frames", [(Image.open(f).convert("RGB"), f.name.replace("-original.webp", "")) for f in frames], 300)
