from pathlib import Path
import subprocess,json,hashlib
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'medieval-wall-native-v1';out.mkdir(exist_ok=False);rows=[]
for video,prefix,times in [(root/'verified/IMG_6382.MOV','medieval',[.25,8.25,87.25,89.25]),(Path('/home/reidsurmeier/risd-godot-ingestion/walkthrough/IMG_6344.MOV'),'hall-entry',[12.5,17.5])]:
 h=hashlib.sha256(video.read_bytes()).hexdigest()
 for sec in times:
  p=out/f'{prefix}-{sec:05.2f}.png';cmd=['ffmpeg','-v','error','-hwaccel','cuda','-noautorotate','-ss',str(sec),'-i',str(video),'-frames:v','1','-vf','transpose=clock','-update','1',str(p)];subprocess.run(cmd,check=True);rows.append({'video':str(video),'video_sha256':h,'seconds':sec,'command':cmd,'output':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()});print(p.name,flush=True)
(out/'manifest.json').write_text(json.dumps({'cuda_decode':True,'cpu_stages':'Native orientation transpose and PNG encoding; no SfM product','frames':rows},indent=2)+'\n')
