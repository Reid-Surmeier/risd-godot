from pathlib import Path
import subprocess,json,hashlib
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'medieval-stair-native-v1';out.mkdir(exist_ok=False);video=root/'verified/IMG_6382.MOV';frames=[]
for t in [15.75,16.75,17.25,18.25,20.75,24.75,26.25,27.25,77.75,78.75,82.75]:
 p=out/f'stair-{t:.2f}.png';cmd=['ffmpeg','-v','error','-hwaccel','cuda','-noautorotate','-ss',str(t),'-i',str(video),'-frames:v','1','-vf','transpose=clock','-update','1',str(p)];subprocess.run(cmd,check=True);frames.append({'seconds':t,'output':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'command':cmd})
(out/'manifest.json').write_text(json.dumps({'video':str(video),'video_sha256':hashlib.sha256(video.read_bytes()).hexdigest(),'cuda_decode':True,'cpu_stages':'Orientation/PNG encoding','frames':frames},indent=2)+'\n');print('Native source saved',len(frames),flush=True)
