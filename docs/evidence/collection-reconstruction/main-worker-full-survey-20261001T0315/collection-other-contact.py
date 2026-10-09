from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
import sys
clip=sys.argv[1];count=int(sys.argv[2]);source=root/'survey-2fps'/clip;out=root/f'{clip}-survey-v1';out.mkdir(exist_ok=True)
frames=sorted(source.glob('*.jpg'));assert len(frames)==count
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
seen=[];sheets=[]
for start in range(0,len(frames),24):
 batch=frames[start:start+24];sheet=Image.new('RGB',(1440,1816),'#171717');draw=ImageDraw.Draw(sheet)
 for j,p in enumerate(batch):
  frame=int(p.stem);seen.append(frame)
  picture=Image.open(p).transpose(Image.Transpose.ROTATE_270).convert('RGB');picture.thumbnail((234,416))
  x=8+(j%6)*240;y=8+(j//6)*450
  sheet.paste(picture,(x,y));draw.text((x,y+420),f'{frame:03d}  {(frame-.5)/2:.2f}s',font=font,fill='white')
 target=out/f'{clip}-{int(batch[0].stem):03d}-{int(batch[-1].stem):03d}.jpg';assert not target.exists()
 sheet.save(target,quality=94);sheets.append(target.name)
assert seen==list(range(1,count+1)) and len(sheets)==(count+23)//24
(out/'manifest.json').write_text(json.dumps(dict(video=clip+'.MOV',frames=count,fps=2,reviewed=False,sheets={n:hashlib.sha256((out/n).read_bytes()).hexdigest() for n in sheets}),indent=2)+'\n')
print(out,len(sheets))
