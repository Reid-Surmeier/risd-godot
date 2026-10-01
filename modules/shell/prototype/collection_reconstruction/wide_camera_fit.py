"""Provisional camera for the wide-shot room comparison; no point-cloud reconstruction.
Run from the repo root with system Python/OpenCV. Canvas annotations are fit inputs,
not independent validation. Native footage and a second entry view judge the room.
"""
import cv2,numpy as np,json
from pathlib import Path
# Annotated authentic Romany canvas corners; hold other objects out of this fit.
image=np.array([[849,646],[949,650],[934,778],[832,776]],dtype=float)
world=np.array([[-2.62,2.596,-4.319],[-2.62,2.596,-5.081],[-2.62,1.644,-5.081],[-2.62,1.644,-4.319]],dtype=float)
f=850.;K=np.array([[f,0,540],[0,f,960],[0,0,1]],dtype=float)
ok,r,t=cv2.solvePnP(world,image,K,None,flags=cv2.SOLVEPNP_ITERATIVE);assert ok
R=cv2.Rodrigues(r)[0];position=(-R.T@t).ravel();forward=R.T@np.array([0,0,1.]);up=R.T@np.array([0,-1.,0]);projection=cv2.projectPoints(world,r,t,K,None)[0][:,0,:];residual=np.linalg.norm(projection-image,axis=1)
assert np.max(residual)<5 and np.isfinite(position).all()
d={'source':'IMG_6380.MOV t224.25s, source dimensions1080x1920','fit':'one catalogue-measured painting canvas plane; not a room reconstruction or point cloud','annotated_pixels':image.tolist(),'world_canvas_corners':world.tolist(),'assumed_focal_px':f,'vertical_fov_degrees':float(np.degrees(2*np.arctan(960/f))),'position':position.tolist(),'target':(position+forward*5).tolist(),'up':up.tolist(),'fit_residual_px':residual.tolist(),'uncertainty':'focal inferred to put the source camera at plausible handheld eye height inside the purple connector; not independently calibrated. Pixel annotations and room metric scale provisional. Other object/door layout comparison required'}
Path('image-work/collection-room-remodel/wide-camera-fit.json').write_text(json.dumps(d,indent=2)+'\n');print(json.dumps(d))
