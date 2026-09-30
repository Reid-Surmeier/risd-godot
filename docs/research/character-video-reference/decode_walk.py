#!/usr/bin/env python3
"""Reconstruct public AC-decomp locomotion joint analysis, without mesh data.
Source commit and reconstruction limitations are recorded in the output.
Inputs remain in a temporary directory; this script does not fetch a ROM.
"""
import re,json,math,argparse,hashlib
p=argparse.ArgumentParser();p.add_argument('--source-dir',type=str,default='/tmp/acgc-motion-source');p.add_argument('--output',default='/tmp/acgc-motion-source/walk-transforms-129.json');p.add_argument('--animation',choices=['walk1','run1','dash1'],default='walk1');args=p.parse_args()
from pathlib import Path
s=(Path(args.source_dir)/'player_anim.c').read_text()
def arr(n):
 a=re.search(r'\b'+n+r'\[\]\s*=\s*\{(.*?)\};',s,re.S).group(1)
 return [int(x) for x in re.findall(r'-?\d+',a)]
f=arr('cKF_ckcb_r_ply_1_'+args.animation+'_tbl');kn=arr('cKF_kn_ply_1_'+args.animation+'_tbl');d=arr('cKF_ds_ply_1_'+args.animation+'_tbl');fx=arr('cKF_c_ply_1_'+args.animation+'_tbl')
ni=di=fi=0; channels=[]; evaluators=[]
def channel(label,animated,scale):
 global ni,di,fi
 if animated:
  n=kn[ni];ni+=1;ks=[d[i:i+3] for i in range(di,di+3*n,3)];di+=3*n
 else:ks=[[1,fx[fi],0],[17,fx[fi],0]];fi+=1
 def calc(frame):
  if not animated:return ks[0][1]*scale
  if frame<=ks[0][0]:return ks[0][1]*scale
  if frame>=ks[-1][0]:return ks[-1][1]*scale
  for a,b in zip(ks,ks[1:]):
   if a[0]<=frame<=b[0]:
    dt=b[0]-a[0];t=(frame-a[0])/dt
    v=(2*t**3-3*t*t+1)*a[1]+(t**3-2*t*t+t)*a[2]*dt/30+(-2*t**3+3*t*t)*b[1]+(t**3-t*t)*b[2]*dt/30
    return int(v+.5)*scale
 evaluators.append(calc)
 samples=[calc(1+i/100) for i in range(1601)]
 channels.append({'label':label,'animated':bool(animated),'range':[round(min(samples),5),round(max(samples),5)],'phase_0_quarter_half_threequarters':[round(calc(x),5) for x in (1,5,9,13)]})
for j,axis in enumerate('XYZ'):channel('root_translation_'+axis,f[0]&(32>>j),1)
names=['root','base','LeftHipBase','LeftThigh','LeftKnee','LeftShoe','RightHipBase','RightThigh','RightKnee','RightShoe','tailbase','tail1','tail2','chest','LeftShoulderBase','LeftUpperArm','LeftForearm','RightShoulderBase','RightUpperArm','RightForearm','hand','HeadBase','mouthbase','mouth','head','feel']
for i,n in enumerate(names):
 for j,axis in enumerate('XYZ'):channel(n+'_'+axis,f[i]&(4>>j),.1)
assert (ni,di,fi)==(len(kn),len(d),len(fx)),((ni,di,fi),(len(kn),len(d),len(fx)))

# Nintendo source Matrix_softcv3_mult: column vectors, parent*T*Rz*Ry*Rx.
def mm(a,b):return [[sum(a[r][k]*b[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
def ident():return [[int(r==c) for c in range(4)] for r in range(4)]
def rot(axis,angle):
 m=ident();a,b={'X':(1,2),'Y':(2,0),'Z':(0,1)}[axis];t=math.radians(angle);c=math.cos(t);s=math.sin(t);m[a][a]=m[b][b]=c;m[a][b]=-s;m[b][a]=s;return m
src=(Path(args.source_dir)/'boy_model.c').read_text().split('cKF_je_r_boy_1_tbl[] = {')[1].split('};')[0]
joints=[];stack=[]
for i,(model,child,x,y,z) in enumerate(re.findall(r'\{\s*(\w+),\s*(\d+),\s*cKF_JOINT_FLAG_DISP_OPA,\s*\{\s*(\d+),\s*(\d+),\s*(\d+)\s*\}',src)):
 while stack and stack[-1][1]==0:stack.pop()
 parent=stack[-1][0] if stack else None
 if stack:stack[-1][1]-=1
 joints.append({'index':i,'name':names[i],'parent':parent,'children':int(child),'translation':[int(n) if int(n)<32768 else int(n)-65536 for n in (x,y,z)]})
 if int(child):stack.append([i,int(child)])
assert len(joints)==26
samples=[]
for k in range(129):
 frame=1+k/8;values=[fn(frame) for fn in evaluators];local=[];world=[];rots=[]
 # Approximation note: quantize source s16 key result and binary angle, but
 # standard sin/cos rather than platform sin_s lookup and no actor callbacks.
 for j in joints:
  i=j['index'];e=values[3+3*i:6+3*i]
  e=[((int(v*65536/360)+32768)%65536-32768)*360/65536 for v in e]
  t=values[:3] if i==0 else j['translation'];t=[int(v+.5) if i==0 else v for v in t]
  m=ident()
  for r in range(3):m[r][3]=t[r]
  for axis,a in zip('ZYX',reversed(e)):m=mm(m,rot(axis,a))
  w=m if j['parent'] is None else mm(world[j['parent']],m)
  rots.append(e);local.append(m);world.append(w)
 samples.append({'phase':k/128,'source_frame':frame,'local_euler_xyz_degrees':rots,'local_matrices_row_major':local,'global_matrices_row_major':world,'global_joint_positions':[ [w[r][3] for r in range(3)] for w in world]})
mapping={'Hips':['root','base'],'LeftUpLeg':['LeftHipBase','LeftThigh'],'LeftLeg':['LeftKnee'],'LeftFoot':['LeftShoe'],'RightUpLeg':['RightHipBase','RightThigh'],'RightLeg':['RightKnee'],'RightFoot':['RightShoe'],'Spine02':['chest'],'LeftShoulder':['LeftShoulderBase'],'LeftArm':['LeftUpperArm'],'LeftForeArm':['LeftForearm'],'RightShoulder':['RightShoulderBase'],'RightArm':['RightUpperArm'],'RightForeArm':['RightForearm'],'neck':['HeadBase'],'Head':['head']}
output={'animation':args.animation,'source_commit':'09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c','status':'source reconstruction, not observed game state or exact runtime output','units':'original model units; local rotations degrees; source translations not meters','matrix_convention':'column vectors; local T*Rz*Ry*Rx; globals parent*local; row-major JSON layout','approximation':'source Hermite; s16 key trunc(value+0.5), binary-angle trunc; standard math sin/cos, no platform lookup/morph/rotation_diff/render callbacks; global actor transform omitted','authored_cycle_phase_intervals':16,'source_effect_phases':{'Left':0,'Right':0.5},'runtime_phase_speed_formula':'.59999996*sqrt(actor.speed*over_speed_normalize_NoneZero/7.5), collision adjustments','joint_hierarchy':joints,'channels':channels,'mapping_recommendation_not_verified':mapping,'unmapped_target_bones':['LeftToeBase','RightToeBase','Spine01','Spine','LeftHand','RightHand','head_end','headfront'],'samples':samples}
output['source_inputs']=[{'path':path,'url':'https://raw.githubusercontent.com/ACreTeam/ac-decomp/'+output['source_commit']+'/'+path,'sha256':hashlib.sha256((Path(args.source_dir)/filename).read_bytes()).hexdigest()} for path,filename in [('src/data/model/player_anim.c','player_anim.c'),('src/data/model/boy_model.c','boy_model.c')]]
Path(args.output).write_text(json.dumps(output,separators=(',',':'))+'\n')
print(args.output)
