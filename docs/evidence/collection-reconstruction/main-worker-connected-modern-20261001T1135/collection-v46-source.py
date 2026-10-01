from pathlib import Path
from PIL import Image,ImageDraw
import subprocess,json,hashlib
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'lion-modern-native-v1';out.mkdir(exist_ok=False);video=root/'verified/IMG_6387.MOV';frames=[]
for t in [2.25,4.25,6.25,8.25,10.25,12.25,14.25,16.25,36.25,38.25,40.25,42.25,44.25,46.25,48.25,50.25,51.25,52.25,53.25,54.25,56.25,58.25,60.25,62.25,64.25,66.25,68.25,70.25,72.25,76.25,80.25,84.25]:
 p=out/f'wide-{t:.2f}.png';cmd=['ffmpeg','-v','error','-hwaccel','cuda','-noautorotate','-ss',str(t),'-i',str(video),'-frames:v','1','-vf','transpose=clock','-update','1',str(p)];subprocess.run(cmd,check=True);frames.append({'seconds':t,'output':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'command':cmd})
(out/'manifest.json').write_text(json.dumps({'video':str(video),'video_sha256':hashlib.sha256(video.read_bytes()).hexdigest(),'cuda_decode':True,'cpu_stages':'Orientation/PNG encoding','frames':frames},indent=2)+'\n')
for name,ts in [('landing',[2.25,4.25,6.25,8.25,10.25,12.25,14.25,16.25,36.25,38.25,40.25,42.25,44.25]),('modern',[46.25,48.25,50.25,51.25,52.25,53.25,54.25,56.25,58.25,60.25,62.25,64.25,66.25,68.25,70.25,72.25,76.25,80.25,84.25])]:
 sheet=Image.new('RGB',(5*240,((len(ts)+4)//5)*446),'#eeeae3');d=ImageDraw.Draw(sheet)
 for i,t in enumerate(ts):
  im=Image.open(out/f'wide-{t:.2f}.png');im.thumbnail((240,422));x=i%5*240;y=i//5*446;sheet.paste(im,(x,y+24));d.text((x+3,y+4),f'6387 {t}s',fill='black')
 sheet.save(out/f'{name}-wide.jpg',quality=93)
print('Saved',len(frames),'CUDA native frames')
