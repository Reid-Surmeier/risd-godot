"""Key the saved Muse frame; retain its original and fit bands to source evidence."""
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
fit=None
if kind=='goltzius':
    fit=json.loads((app/'goltzius-source-fit.json').read_text())
    # ponytail: manually selected planar corners; nonplanar frame depth limits precision.
    margins=[round(m*hh/canvas[1]) for m in fit[1]['margins_m']]
    left,top,right,bottom=margins
    oldx=[0,x0,x0+ww,w];oldy=[0,y0,y0+hh,h]
    newx=[0,left,left+ww,left+ww+right];newy=[0,top,top+hh,top+hh+bottom]
    fitted=Image.new('RGBA',(newx[-1],newy[-1]))
    original=Image.fromarray(a)
    for j in range(3):
        for i in range(3):
            piece=original.crop((oldx[i],oldy[j],oldx[i+1],oldy[j+1]))
            fitted.paste(piece.resize((newx[i+1]-newx[i],newy[j+1]-newy[j]),Image.Resampling.LANCZOS),(newx[i],newy[j]))
    assert np.array_equal(np.array(fitted)[top:top+hh,left:left+ww],a[y0:y0+hh,x0:x0+ww]),'Painting opening changed'
    a=np.array(fitted);h,w=a.shape[:2];x0,y0=left,top
Image.fromarray(a).save(app/'trial'/f'{kind}-frame.png')
g={'canvas_m':canvas,'margins_px':[x0,y0,w-x0-ww,h-y0-hh],'texture_size':[w,h],
'opening_aspect':ww/hh,'catalogue_aspect':canvas[0]/canvas[1],'depth_m':.09,'canvas_inset_m':.035,
'depth_note':'Existing Main Hall profile depth reused, unmeasured',
'geometry':'native nine-slice preserves band thickness and corrects opening aspect; no room placement yet',
'source_sha256':hashlib.sha256(native.read_bytes()).hexdigest()}
if fit:
    g['source_fit']={'video':'IMG_6386','selected_time_seconds':fit[1]['time'],'crosscheck_time_seconds':fit[0]['time'],
        'target_margins_m':fit[1]['margins_m'],'crossframe_margin_difference_m':(np.array(fit[1]['margins_m'])-fit[0]['margins_m']).tolist(),
        'note':'Opening pixels unchanged; each Muse band compressed independently. Manual planar corner fit is provisional because the frame is stepped/nonplanar.'}
(app/'trial'/f'{kind}-frame-geometry.json').write_text(json.dumps(g,indent=2)+'\n');print(g)
