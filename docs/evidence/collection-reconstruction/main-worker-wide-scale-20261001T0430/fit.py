"""Unpaid planar measurement from two native wide views; never a room acceptance.
Run: python3 docs/evidence/collection-reconstruction/main-worker-wide-scale-20261001T0430/fit.py
No assumed camera focal length or point-cloud input. Keep the original native sources.
"""
from pathlib import Path
import cv2,numpy as np,json,hashlib
root=Path(__file__).resolve().parent
cases=[dict(source='portal-distant-native.png',seconds=2.25,corners=[[660.5,916.25],[707.25,917.75],[705.5,996.75],[658.5,995.75]],door=[595,1020],corner=[750,1020]),dict(source='../main-worker-room-layout-20260930T2230/source-portal-native.png',seconds=3.75,corners=[[305.8,941.2],[355.4,942.8],[353,1026.5],[304.2,1025.3]],door=[215,1048],corner=[397,1048])]
record=json.loads((root/'lawrence-sarah.json').read_text())[0]
assert record['objectNumber']=='60.039' and record['dimensions'].startswith('235.1 x 142.9 cm')
width,height=1.429,2.351
plane=np.array([[-width/2,height],[width/2,height],[width/2,0],[-width/2,0]],dtype=np.float32)
results=[]
for case in cases:
 source=root/case['source'];assert source.exists()
 points=np.array(case['corners'],dtype=np.float32);H=cv2.getPerspectiveTransform(points,plane)
 project=lambda p:cv2.perspectiveTransform(np.array([p],dtype=np.float32),H)[0]
 assert np.max(np.linalg.norm(project(case['corners'])-plane,axis=1))<1e-4
 measured=project([case['door'],case['corner']]);full_width=float(2*(measured[1,0]-measured[0,0]))
 assert 8<full_width<12,'Annotation scale/order or catalogue dimensions changed: review source'
 sensitivity=[]
 for vertex in range(4):
  for axis in range(2):
   for delta in [-2,2]:
    altered=points.copy();altered[vertex,axis]+=delta
    h=cv2.getPerspectiveTransform(altered,plane)
    m=cv2.perspectiveTransform(np.array([[case['door'],case['corner']]],dtype=np.float32),h)[0]
    sensitivity.append(float(2*(m[1,0]-m[0,0])))
 results.append(dict(**case,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),end_wall_relative_to_canvas_m=measured.tolist(),width_m_assuming_centered_door=full_width,corner_annotation_2px_sensitivity_m=[min(sensitivity),max(sensitivity)],canvas_bottom_estimate_m=float(-measured[:,1].mean())))
assert abs(results[0]['width_m_assuming_centered_door']-results[1]['width_m_assuming_centered_door'])/10<.2,'Reciprocal views disagree: review annotations'
out=dict(accepted=False,method='Two independent canvas-plane rectifications; no focal length, SfM model or point cloud used',catalogue=dict(id=record['id'],accession=record['objectNumber'],url=record['url'],dimensions=record['dimensions'],sha256=hashlib.sha256((root/'lawrence-sarah.json').read_bytes()).hexdigest()),cases=results,limitations=['Far canvas spans only47–50 native pixels; blur/distortion/manual corners limit accuracy','Door centre and right floor corner are manually approximated; full width assumes centred doorway','Two-pixel corner perturbations are sensitivity bounds, not statistical confidence intervals','Canvas is recessed behind frame; baseboard/floor and exact hanging height are unaccepted','Parallel end-wall width check does not determine Hall length or adjoining room dimensions','Saved10m width is compatible; saved26.3m length still requires independent near/far source constraints'])
# The two-pixel-scale far-plane fit cannot validate a full camera pose.
# ponytail: this diagnostic freezes authored hanging/centre values; near anchors are needed to fit rooms.
world=np.array([[3.115-width/2,.6+height,-26.3],[3.115+width/2,.6+height,-26.3],[3.115+width/2,.6,-26.3],[3.115-width/2,.6,-26.3]],dtype=float)
K=np.array([[891.,0,540.],[0,891.,960.],[0,0,1.]])
old=[[[660.5,916.25],[707.25,917.75],[705.5,990.5],[658.5,989.75]],[[305.8,941.2],[355.4,942.8],[353,1021.6],[304.2,1020.4]]]
poses=[]
for i,case in enumerate(cases):
 for label,points in [('superseded_canvas_bottom',old[i]),('corrected_canvas_bottom',case['corners'])]:
  ok,r,t=cv2.solvePnP(world,np.array(points,dtype=float),K,None,flags=cv2.SOLVEPNP_ITERATIVE);assert ok
  R=cv2.Rodrigues(r)[0];position=(-R.T@t).ravel();residual=np.linalg.norm(cv2.projectPoints(world,r,t,K,None)[0][:,0,:]-points,axis=1)
  poses.append(dict(seconds=case['seconds'],annotation=label,camera_position=position.tolist(),max_residual_px=float(residual.max()),accepted=False))
out['rejected_pose_diagnostic']=dict(assumed_focal_native_px=891,unverified_model_values=dict(hall_length=26.3,n2_center_x=3.115,n2_canvas_bottom=.6),reason='Superseded lower-edge marks generated below-floor cameras; corrected marks still give inconsistent positions, including outside the Hall and in front of portal. Small pixel errors do not verify pose.',poses=poses)
(root/'result.json').write_text(json.dumps(out,indent=2)+'\n')
print('Unaccepted width checks:',*[round(r['width_m_assuming_centered_door'],3) for r in results])
