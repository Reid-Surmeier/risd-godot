from PIL import Image, ImageFilter, ImageChops
import sys
im=Image.open(sys.argv[1]).convert("L").resize((720,720)).crop((100,120,350,175))
d=ImageChops.subtract(im.filter(ImageFilter.MedianFilter(3)),im)
n=sum(v>30 for v in d.getdata())
print(f"isolated dark floor pixels: {n}; reference limit: 2")
assert n <= 2, "browser floor speckling exceeds matched native/reference"
