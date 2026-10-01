"""Fixed registration + whole-viewport evidence; existing OpenCV/Pillow, no synthesis.
Usage: python compare_reference.py <record-project> <source-excerpt>
The original upload's input, aspect settings and ground scale remain uncertain.
"""
from pathlib import Path
import sys,json,hashlib,subprocess,tempfile,math
import cv2,numpy as np
from PIL import Image,ImageDraw,ImageOps
HERE=Path(__file__).resolve().parent
project=Path(sys.argv[1]);clip=Path(sys.argv[2]);out=HERE/'evidence'
if len(sys.argv)>3:out=out/sys.argv[3]
out.mkdir(parents=True,exist_ok=True)
cap=cv2.VideoCapture(str(clip));assert cap.isOpened()
cap.set(cv2.CAP_PROP_POS_FRAMES,30);frames=[]
for i in range(61):
 ok,f=cap.read();assert ok;frames.append(f)
cap.release()
grays=[cv2.cvtColor(f,cv2.COLOR_BGR2GRAY) for f in frames]
mask=np.zeros_like(grays[0]);mask[150:350,70:410]=255;mask[145:280,270:370]=0;mask[255:360,200:355]=0
points=cv2.goodFeaturesToTrack(grays[0],maxCorners=80,qualityLevel=.02,minDistance=8,mask=mask)
assert points is not None and len(points)>=12
initial=points.copy();previous=grays[0];valid=np.ones(len(points),dtype=bool);tracks=[]
for index,gray in enumerate(grays):
 if index:
  current,status,_=cv2.calcOpticalFlowPyrLK(previous,gray,points,None,winSize=(21,21),maxLevel=3)
  back,backstatus,_=cv2.calcOpticalFlowPyrLK(gray,previous,current,None,winSize=(21,21),maxLevel=3)
  valid &= status[:,0].astype(bool)&backstatus[:,0].astype(bool)&(np.linalg.norm(back-points,axis=2)[:,0]<1)
  points=current
 assert valid.sum()>=6
 H,inliers=cv2.findHomography(initial[valid],points[valid],cv2.RANSAC,2)
 assert H is not None and inliers.sum()>=6
 projected=cv2.perspectiveTransform(initial[valid],H)
 errors=np.linalg.norm(projected-points[valid],axis=2)[:,0]
 rms=float(np.sqrt(np.mean(errors[inliers[:,0].astype(bool)]**2)))
 tracks.append({'frame':index,'time':602+index/30,'tracked':int(valid.sum()),'inliers':int(inliers.sum()),'H':H.tolist(),'inlier_rms_px':rms})
 previous=gray
assert max(t['inlier_rms_px'] for t in tracks)<2
anchors=[(0,[320,233]),(30,[320,230]),(60,[316,244])]
registered=[]
for index,anchor in anchors:
 point=cv2.perspectiveTransform(np.array([[anchor]],dtype=np.float32),np.linalg.inv(np.array(tracks[index]['H'])))[0,0]
 registered.append({'source_time':602+index/30,'observed_ground_anchor_px':anchor,'initial_ground_projection_px':point.tolist()})
trace=json.loads((project/'record.json').read_text())
assert trace['whole_viewport'] and len(trace['frames'])>=60
gait=trace['reference_gait']
source_distance=float(np.linalg.norm(np.array(registered[-1]['initial_ground_projection_px'])-registered[0]['initial_ground_projection_px']))
# Same initial camera projection for target ground travel; comparable image-space quantity only.
focal=720/(2*math.tan(math.radians(10)))
def project_ground(z):return 360+focal*(.85/math.sqrt(2)+z/math.sqrt(2))/(22+.85/math.sqrt(2)-z/math.sqrt(2))
target_distance=project_ground(trace['frames'][59]['z'])-project_ground(trace['frames'][0]['z'])
receipt={'source':'https://www.youtube.com/watch?v=Fd0g57lSedA&t=602s','source_clip_sha256':hashlib.sha256(clip.read_bytes()).hexdigest(),'source_window':[602,604],'source_encoded_fps':30,'target_fps':30,'opencv_version':cv2.__version__,'initial_features':initial[:,0].tolist(),'ground_tracks':tracks,'source_manual_ground_anchors':registered,'manual_anchor_uncertainty_px':5,'fixed_registration':{'source_crop_xyxy':[265,140,380,270],'target_crop_xyxy':[390,275,570,430],'source_uniform_scale':2,'target_uniform_scale':1.10,'one_body_span_fit_px':[76,138],'body_span_uncertainty_px':5,'phase_offset_seconds':0,'per_frame_warp':False,'encoded_aspect_preserved':True,'camera_yaw_matched':False},'normalized_initial_ground_projection':{'source_distance_px':source_distance,'source_body_spans':source_distance/76,'target_distance_px':target_distance,'target_body_spans':target_distance/138,'world_speed_matched':False,'note':'Camera-relative diagnostic, not meters or exact fit. Source guided movement/input, nonlinear projection extrapolation, outfit landmarks and encoded aspect remain uncertain.'},'exact_match':False,'paid_calls':0}
with tempfile.TemporaryDirectory(prefix='character-fixed-reference-') as temporary:
 p=Path(temporary);whole=[];poses=[]
 for i in range(60):
  source=Image.fromarray(cv2.cvtColor(frames[i],cv2.COLOR_BGR2RGB));target=Image.open(project/f'record-{i:03d}.png').convert('RGB')
  wide=Image.new('RGB',(980,410),'#18202b');draw=ImageDraw.Draw(wide)
  wide.paste(ImageOps.pad(source,(480,360),color='#18202b'),(5,30));wide.paste(ImageOps.pad(target,(480,360),color='#18202b'),(495,30))
  draw.text((5,8),f'EmuRetro original-game upload / {602+i/30:.3f}s / input unknown',fill='white')
  draw.text((495,8),f'Native {gait} / {i/30:.3f}s',fill='white')
  draw.text((5,394),'Whole view: camera/background motion retained. Different environments/outfits; no exact-match claim.',fill='white')
  wide.save(p/f'whole-{i:03d}.png');whole.append(wide)
  pair=Image.new('RGB',(640,366),'#18202b');draw=ImageDraw.Draw(pair)
  for column,image,crop,scale,anchor in [(0,source,(265,140,380,270),2,(55,93)),(1,target,(390,275,570,430),1.10,(90,145))]:
   cut=image.crop(crop);cut=cut.resize((round(cut.width*scale),round(cut.height*scale)),Image.Resampling.NEAREST)
   x=column*320+round(157-anchor[0]*scale);y=round(245-anchor[1]*scale)
   pair.paste(cut,(x,y));draw.line((column*320+20,245,column*320+300,245),fill='#e6c95c')
  draw.text((5,8),'Original / fixed crop and uniform scale',fill='white');draw.text((325,8),f'{gait} / fixed registration',fill='white')
  draw.text((5,345),'One body-scale fit; no phase warp. Hat/outfit and capture settings differ.',fill='white')
  pair.save(p/f'pose-{i:03d}.png');poses.append(pair)
 for name,items in [('whole-view',whole),('registered-pose',poses)]:
  prefix='whole' if name=='whole-view' else 'pose'
  subprocess.run(['ffmpeg','-v','error','-y','-framerate','30','-i',str(p/(prefix+'-%03d.png')),'-c:v','libx264','-pix_fmt','yuv420p','-movflags','+faststart',str(out/(name+'.mp4'))],check=True)
  items[0].save(out/(name+'.gif'),save_all=True,append_images=items[3::3],duration=100,loop=0)
  sheet=Image.new('RGB',(items[0].width,items[0].height*3))
  for row,index in enumerate([6,24,42]):sheet.paste(items[index],(0,row*items[0].height))
  sheet.save(out/(name+'-poses.jpg'))
receipt['artifact_hashes']={name:hashlib.sha256((out/name).read_bytes()).hexdigest() for name in ['whole-view.mp4','whole-view.gif','whole-view-poses.jpg','registered-pose.mp4','registered-pose.gif','registered-pose-poses.jpg']}
receipt['target_gait']=gait
(out/'comparison.json').write_text(json.dumps(receipt,indent=2)+'\n')
print('PASS fixed-aspect/scale registration, whole viewport and',len(tracks),'source ground fits; exact fidelity open')
