from pathlib import Path
import subprocess,json,hashlib
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'medieval-grille-native-v1';out.mkdir(exist_ok=False);video=root/'verified/IMG_6382.MOV';vh=hashlib.sha256(video.read_bytes()).hexdigest();rows=[]
for sec in [12.25,13.25,14.25,88.75]:
 p=out/f'grille-{sec:05.2f}.png';cmd=['ffmpeg','-v','error','-hwaccel','cuda','-noautorotate','-ss',str(sec),'-i',str(video),'-frames:v','1','-vf','transpose=clock','-update','1',str(p)];subprocess.run(cmd,check=True);rows.append({'seconds':sec,'command':cmd,'output':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()});print(p.name,flush=True)
(out/'manifest.json').write_text(json.dumps({'video':str(video),'video_sha256':vh,'cuda_decode':True,'cpu_stages':'Orientation and PNG encoding','frames':rows},indent=2)+'\n')
