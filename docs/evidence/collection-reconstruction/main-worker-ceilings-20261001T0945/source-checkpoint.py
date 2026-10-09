from pathlib import Path
import json,hashlib,shutil,subprocess
from PIL import Image
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion');out=root/'lowpoly-room-v43-ceilings';e=Path('docs/evidence/collection-reconstruction/main-worker-ceilings-20261001T0945');e.mkdir(exist_ok=True)
video=root/'verified/IMG_6383.MOV';rows=[]
for sec in ['2.25','38.25','62.25']:
 p=root/'renaissance-ceiling-native-v1'/f'wide-{sec}.png';rows.append({'seconds':float(sec),'command':['ffmpeg','-v','error','-hwaccel','cuda','-noautorotate','-ss',sec,'-i',str(video),'-frames:v','1','-vf','transpose=clock','-update','1',str(p)],'output':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
 im=Image.open(p);assert im.size==(1080,1920);im.resize((540,960),Image.Resampling.LANCZOS).save(e/f'renaissance-{sec}-source.jpg',quality=92)
manifest={'video':str(video),'video_sha256':hashlib.sha256(video.read_bytes()).hexdigest(),'cuda_decode':True,'cpu_stages':'Orientation and PNG encoding','frames':rows};s=json.dumps(manifest,indent=2)+'\n';(root/'renaissance-ceiling-native-v1/manifest.json').write_text(s);(e/'renaissance-source-manifest.json').write_text(s)
old=Path('docs/evidence/collection-reconstruction/main-worker-gabled-frame-20261001T0925')
for n in ['medieval-portal-wall-wide.png','grille-88.75-review.jpg']:shutil.copyfile(old/n,e/('v42-'+n))
for n in ['medieval-portal-wall-wide.png','renaissance-wide.png','medieval-walk.png','renaissance-walk.png','loop-overview.png','ceiling-visibility.json']:shutil.copyfile(out/'evidence'/n,e/('unbaked-'+n))
architecture={'date_utc':'2026-10-01','sources':['IMG_6383 2.25/62.25s','IMG_6382 88.75s'],'finding':'Both rooms have flat pale plaster ceilings with tracks/spotlights. The omitted opaque model ceilings exposed the Hall skylight at eye level. Native low polygon slabs reuse existing Muse plaster; show below 3.4m, hide above, always included during bake preparation.','height_m':{'Renaissance':3.5,'medieval':4.25},'metric_accepted':False,'presentation_checks':'Unbaked eye and elevated camera assertions pass; final baked proof pending.','unfinished':['Source-fitted track/spot positions and fixture count','Grille right of medieval portal','East wall stone fragment and stairs door','Room dimensions/placements','Remaining objects, case contents, lighting, modern gallery, stairs and auditorium'],'paid_calls':0}
(e/'architecture-review.json').write_text(json.dumps(architecture,indent=2)+'\n');shutil.copyfile(__file__,e/'source-checkpoint.py')
print(e)
