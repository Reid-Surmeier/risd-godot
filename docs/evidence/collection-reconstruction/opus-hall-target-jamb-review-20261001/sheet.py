"""Contact sheet: sheet.py out.jpg cols cellw label=path ..."""
import sys
from PIL import Image, ImageDraw
out,cols,w=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
cells=[]
for item in sys.argv[4:]:
    label,path=item.split('=',1)
    im=Image.open(path).convert('RGB'); im=im.resize((w,round(im.height*w/im.width)))
    d=ImageDraw.Draw(im); d.rectangle([0,0,w,16],fill=(0,0,0)); d.text((4,2),label,fill=(255,255,255))
    cells.append(im)
h=max(c.height for c in cells); rows=-(-len(cells)//cols)
sheet=Image.new('RGB',(cols*w,rows*h),(32,32,32))
for i,c in enumerate(cells): sheet.paste(c,((i%cols)*w,(i//cols)*h))
sheet.save(out,quality=88)
