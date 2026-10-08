"""Lay pictures side by side at one height. usage: sheet.py OUT.jpg HEIGHT IN [IN ...] [--max-kb N]"""
import sys, io
from PIL import Image
a = sys.argv[1:]; kb = None
if '--max-kb' in a: i = a.index('--max-kb'); kb = int(a[i + 1]); a = a[:i] + a[i + 2:]
out, h, ins = a[0], int(a[1]), a[2:]
ims = [Image.open(p).convert('RGB') for p in ins]
ims = [im.resize((round(im.width * h / im.height), h), Image.LANCZOS) for im in ims]
sheet = Image.new('RGB', (sum(i.width for i in ims) + 8 * (len(ims) - 1), h), 'white'); x = 0
for im in ims: sheet.paste(im, (x, 0)); x += im.width + 8
q = 90
while True:
    b = io.BytesIO(); sheet.save(b, 'JPEG', quality=q, optimize=True)
    if not kb or b.tell() <= kb * 1024 or q <= 40: break
    q -= 5
open(out, 'wb').write(b.getvalue()); print(out, sheet.size, 'q', q, b.tell() // 1024, 'KB')
