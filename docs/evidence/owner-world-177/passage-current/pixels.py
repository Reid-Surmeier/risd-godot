"""Background-only comparison in the visible interior passage crop (720 reference)."""
import json,sys
from pathlib import Path
from PIL import Image
import numpy as np
normal=np.array(Image.open(sys.argv[1]).convert('RGB'));magenta=np.array(Image.open(sys.argv[2]).convert('RGB'))
h,w,_=normal.shape
assert normal.shape==magenta.shape
crop=(slice(round(h*400/480),round(h*470/480)),slice(round(w*300/720),round(w*420/720)))
a,b=normal[crop],magenta[crop]
mask=(b[:,:,0]>160)&(b[:,:,2]>160)&(b[:,:,1]<80)&(np.max(np.abs(a.astype(int)-b.astype(int)),axis=2)>60)
count=int(mask.sum());print(json.dumps({'size':[w,h],'interior_background_pixels':count}))
sys.exit(0 if count==0 else 1)
