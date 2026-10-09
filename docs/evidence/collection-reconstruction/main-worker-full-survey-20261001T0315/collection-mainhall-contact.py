from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
source=root/'survey-2fps/IMG_6380';out=root/'main-hall-survey-v1';out.mkdir(exist_ok=True)
frames=sorted(source.glob('*.jpg'));assert len(frames)==521
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
seen=[];sheets=[]
for start in range(0,len(frames),24):
 batch=frames[start:start+24];sheet=Image.new('RGB',(1440,1816),'#171717');draw=ImageDraw.Draw(sheet)
 for j,p in enumerate(batch):
  frame=int(p.stem);seen.append(frame)
  picture=Image.open(p).transpose(Image.Transpose.ROTATE_270).convert('RGB');picture.thumbnail((234,416))
  x=8+(j%6)*240;y=8+(j//6)*450
  sheet.paste(picture,(x,y));draw.text((x,y+420),f'{frame:03d}  {(frame-.5)/2:.2f}s',font=font,fill='white')
 target=out/f'IMG_6380-{int(batch[0].stem):03d}-{int(batch[-1].stem):03d}.jpg';assert not target.exists()
 sheet.save(target,quality=94);sheets.append(target.name)
assert seen==list(range(1,522)) and len(sheets)==22
(out/'manifest.json').write_text(json.dumps(dict(video='IMG_6380.MOV',frames=521,fps=2,reviewed=False,sheets={n:hashlib.sha256((out/n).read_bytes()).hexdigest() for n in sheets}),indent=2)+'\n')
print(out,len(sheets))
