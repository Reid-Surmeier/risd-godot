"""Replay source selection, guard registered cameras and quantify the empty floor search."""
import hashlib,inspect,json,runpy,shutil,sys,tempfile
from pathlib import Path
import numpy as np
import pycolmap
from PIL import Image,ImageDraw
sys.path.insert(0,'modules/shell/prototype/collection_reconstruction')
from measurements import upright,project,raw
here=Path(__file__).parent
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
trial=root/'native-exit-floor-tracks-v2'
report=json.loads((trial/'result.json').read_text())
selection=report['selection'];training=selection['training']
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert all(sha(Path(p))==h for p,h in report['inputs_sha256'].items())
assert not report['navigation_accepted'] and report['floor_pixels_used_for_query_pose']
assert report['registered_query_cameras']==selection['reserved']
assert not set(training)&set(selection['reserved'])
assert json.loads((trial/'source-candidates.json').read_text())==[]==report['candidates']
assert json.loads((here/'source-floor-candidates.json').read_text())['candidates']==[]
model=pycolmap.Reconstruction(root/'sfm-strict-doorway-v1/sparse/0')
views={v.name:v for v in model.images.values() if v.has_pose}
for n in training+selection['reserved']:
 pose=views[n].cam_from_world();camera=model.cameras[views[n].camera_id]
 point=pose.inverse()*np.array([.1,.2,3.])
 assert np.linalg.norm(raw(project(camera,pose,point[None])[0])-camera.img_from_cam(pose*point))<1e-8
floor={};pixels={};photos={}
with tempfile.TemporaryDirectory(prefix='collection-floor-check-') as scratch:
 database=Path(scratch)/'database.db';shutil.copyfile(trial/'database.db',database)
 with pycolmap.Database.open(database) as db:
  records={i.name:i for i in db.read_all_images()}
  for n in training:
   px=upright(db.read_keypoints(records[n].image_id)[:,:2].astype(float)/1.5);pixels[n]=px
   mask=Image.new('1',(720,1280));ImageDraw.Draw(mask).polygon([tuple(p) for p in selection['floor_polygons_upright'][n]],fill=1)
   floor[n]=np.array([0<=p[0]<720 and 0<=p[1]<1280 and mask.getpixel(tuple(np.minimum(np.rint(p).astype(int),[719,1279]))) for p in px],dtype=bool)
  matches=db.read_matches(records[training[0]].image_id,records[training[1]].image_id)
  masked=sum(bool(floor[training[0]][a] and floor[training[1]][b]) for a,b in matches)
  assert masked==0
 counts={n:dict(total=len(pixels[n]),in_frozen_floor_mask=int(floor[n].sum())) for n in training}
 for n in training:
  photo=Image.open(root/selection['images'][n]).transpose(Image.Transpose.ROTATE_270).convert('RGB');draw=ImageDraw.Draw(photo)
  draw.line([tuple(np.array(p)*1.5) for p in selection['floor_polygons_upright'][n]+[selection['floor_polygons_upright'][n][0]]],fill='yellow',width=3)
  for p in pixels[n][floor[n]]:
   x,y=p*1.5;draw.ellipse((x-5,y-5,x+5,y+5),outline='cyan',width=2)
  draw.rectangle((0,0,1080,50),fill='black');draw.text((10,10),n+': detected floor features; ZERO source pairs',fill='white')
  photo.save(here/(Path(n).stem+'-floor-detections.png'))
 # Registered reserve fails closed unless diagnostic scope is explicit, before CUDA extraction.
 bad=dict(selection);bad.pop('allow_registered_reserved')
 path=Path(scratch)/'bad-selection.json';path.write_text(json.dumps(bad))
 previous=sys.argv;sys.argv=['native_floor_tracks.py',str(path),str(Path(scratch)/'rejected')]
 try:
  runpy.run_path('modules/shell/prototype/collection_reconstruction/native_floor_tracks.py',run_name='__main__')
 except AssertionError as error:assert 'explicit correlated-diagnostic scope' in str(error)
 else:raise AssertionError('Registered-camera scope guard failed')
 finally:sys.argv=previous
 # The original wall-only setup replays exactly; stop before feature extraction.
 old_selection=Path('docs/evidence/collection-reconstruction/heartbeat-20260930T1600/native-selection.json')
 old_report=json.loads((root/'native-floor-tracks-v1/result.json').read_text())
 old_poses=json.loads((root/old_report['selection']['pose_source']).read_text())
 class SetupChecked(Exception):pass
 def stop_before_cuda(*args,**kwargs):
  state=inspect.currentframe().f_back.f_locals
  assert state['registered_queries']==[]
  for row in old_poses['rows']:
   assert np.allclose(state['poses'][row['image']].matrix(),row['cam_from_world'],atol=1e-8)
   actual=state['cameras'][row['image']];expected=pycolmap.Camera(row['camera'])
   assert (actual.model,actual.width,actual.height)==(expected.model,expected.width,expected.height)
   assert np.allclose(actual.params,expected.params,atol=1e-12)
  raise SetupChecked()
 extraction=pycolmap.extract_features;pycolmap.extract_features=stop_before_cuda
 sys.argv=['native_floor_tracks.py',str(old_selection),str(Path(scratch)/'old-setup')]
 try:
  runpy.run_path('modules/shell/prototype/collection_reconstruction/native_floor_tracks.py',run_name='__main__')
 except SetupChecked:pass
 else:raise AssertionError('Original pose setup did not replay')
 finally:sys.argv=previous;pycolmap.extract_features=extraction
 # Completed trials reject overwrite before reading selection or invoking CUDA.
 sys.argv=['native_floor_tracks.py',str(path),str(trial)]
 try:
  runpy.run_path('modules/shell/prototype/collection_reconstruction/native_floor_tracks.py',run_name='__main__')
 except FileExistsError:pass
 else:raise AssertionError('Completed trial overwrite accepted')
 finally:sys.argv=previous
assert all(sha(Path(p))==h for p,h in report['inputs_sha256'].items())
result=dict(features=counts,source_pair_raw_matches=len(matches),source_pair_masked_matches=masked,
 source_freeze_check=True,registered_scope_guard=True,overwrite_guard=True,camera_round_trip=True,
 source_inputs_preserved=True,original_wall_pose_setup_replay=True,navigation_accepted=False,cost_usd=0)
(here/'native-checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
