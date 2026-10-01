"""Key the saved Muse frame and measure its blank opening; preserve native pixels."""
from pathlib import Path
import cv2,numpy as np,json,hashlib,sys
from PIL import Image
app=Path(__file__).resolve().parent
kind=sys.argv[1] if len(sys.argv)>1 else 'fetti'
assert kind in ['fetti','goltzius']
canvas=[.781,.895] if kind=='fetti' else [.345,.510]
native=app/'trial'/f'{kind}-frame-original.webp'
a=np.array(Image.open(native).convert('RGBA'));hsv=cv2.cvtColor(a[:,:,:3],cv2.COLOR_RGB2HSV)
chroma=(hsv[:,:,0]>=125)&(hsv[:,:,0]<=175)&(hsv[:,:,1]>70)&(hsv[:,:,2]>35)
a[chroma,3]=0;a[chroma,:3]=[162,124,55];y,x=np.where(a[:,:,3]>0);a=a[y.min():y.max()+1,x.min():x.max()+1]
white=(np.min(a[:,:,:3],axis=2)>245).astype('uint8');count,labels,stats,centers=cv2.connectedComponentsWithStats(white)
h,w=white.shape;label=int(labels[h//2,w//2]);assert label>0
x0,y0,ww,hh=map(int,stats[label,:4]);assert ww>500 and hh>700
# Exclude 2 antialiased edge pixels when checking the white interior; do not alter the native raster.
assert white[y0+2:y0+hh-2,x0+2:x0+ww-2].mean()>.995
Image.fromarray(a).save(app/'trial'/f'{kind}-frame.png')
g={'canvas_m':canvas,'margins_px':[x0,y0,w-x0-ww,h-y0-hh],'texture_size':[w,h],
'opening_aspect':ww/hh,'catalogue_aspect':canvas[0]/canvas[1],'depth_m':.09,'canvas_inset_m':.035,
'depth_note':'Existing Main Hall profile depth reused, unmeasured',
'geometry':'native nine-slice preserves band thickness and corrects opening aspect; no room placement yet',
'source_sha256':hashlib.sha256(native.read_bytes()).hexdigest()}
(app/'trial'/f'{kind}-frame-geometry.json').write_text(json.dumps(g,indent=2)+'\n');print(g)
