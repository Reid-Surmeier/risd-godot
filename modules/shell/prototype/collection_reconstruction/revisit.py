"""Revisit failed held-out views at 6 fps; evidence only, not validation training."""
import json,pathlib,subprocess
from PIL import Image,ImageDraw
root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
failures=[r for r in json.loads((root/'heldout-v2/result.json').read_text()) if not r['supported']]
records=[]
for r in failures:
 clip,frame=r['image'].split('/');t=(int(frame[:-4])-1)/2;start=max(0,t-3)
 out=root/'revisits'/f'{clip}-{t:g}s';out.mkdir(parents=True,exist_ok=True)
 subprocess.run(['ffmpeg','-y','-hide_banner','-loglevel','error','-hwaccel','cuda','-hwaccel_output_format','cuda','-ss',str(start),'-noautorotate','-i',str(root/'verified'/f'{clip}.MOV'),'-t','6','-vf','scale_cuda=1280:720:format=yuv420p,hwdownload,format=yuv420p,fps=6','-q:v','2',str(out/'%04d.jpg')],check=True)
 frames=sorted(out.glob('*.jpg'));sheet=Image.new('RGB',(1280,6*204),'white');d=ImageDraw.Draw(sheet)
 for i,f in enumerate(frames[::2]):
  im=Image.open(f);im.thumbnail((320,180));x=i%4*320;y=i//4*204;sheet.paste(im,(x,y));d.text((x+3,y+183),f'{clip} {start+i/3:.2f}s nominal',fill='black')
 sheet.save(out/'contact.jpg');records.append(dict(clip=clip,failed_time=t,start=start,fps=6,frames=len(frames),use='reference review only; held-out model remains frozen'))
(root/'revisits/manifest.json').write_text(json.dumps(records,indent=2));print(records)
