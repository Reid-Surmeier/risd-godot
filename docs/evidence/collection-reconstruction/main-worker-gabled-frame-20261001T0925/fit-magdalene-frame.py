"""Fit Muse gold to the source gable; keep the original panel separate.
Run with system Python. Native output is immutable; derivatives stay in trial/.
"""
from pathlib import Path
import hashlib,json
import cv2,numpy as np
from PIL import Image
app=Path(__file__).resolve().parent
source=app/'inventory-catalogue/memmi-magdalene-zoom-0.jpg';native=app/'trial/magdalene-frame-v2b-original.webp'
original=np.array(Image.open(source).convert('RGB'));gold=np.array(Image.open(native).convert('RGB'))
guide=json.loads((app/'magdalene-frame-guide-v2.json').read_text());hole=np.array(guide['painted_infill_polygon_px'],dtype=float)
mask=cv2.morphologyEx((original.max(axis=2)>20).astype('uint8'),cv2.MORPH_CLOSE,np.ones((5,5),dtype='uint8'));contours,_=cv2.findContours(mask,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE);raw=max(contours,key=cv2.contourArea)
outline=cv2.approxPolyDP(raw,6,True)[:,0,:].astype(float)
def area(p):return np.sum(p[:,0]*np.roll(p[:,1],-1)-p[:,1]*np.roll(p[:,0],-1))/2
if area(outline)<0:outline=outline[::-1]
# Split the single ring at the source shoulder/base into four simple native polygons.
for y in [1158.,2158.]:
 crossings=[]
 for i,(a,b) in enumerate(zip(outline,np.roll(outline,-1,axis=0))):
  if min(a[1],b[1])<y<max(a[1],b[1]):crossings.append((i,np.array([a[0]+(b[0]-a[0])*(y-a[1])/(b[1]-a[1]),y])))
 candidates=[q[1][0] for q in crossings]+outline[outline[:,1]==y,0].tolist()
 assert len(candidates)>=2,(y,len(candidates))
 extremes=[min(candidates),max(candidates)]
 crossings=[q for q in crossings if q[1][0] in extremes]
 for i,p in sorted(crossings,reverse=True,key=lambda q:q[0]):outline=np.insert(outline,i+1,p,axis=0)
shoulder=sorted(np.where(outline[:,1]==1158)[0],key=lambda i:outline[i,0]);base=sorted(np.where(outline[:,1]==2158)[0],key=lambda i:outline[i,0]);ls,rs=shoulder[0],shoulder[-1];lb,rb=base[0],base[-1]
assert min(cv2.pointPolygonTest(outline.astype('float32'),tuple(map(float,q)),True) for q in hole)>0,'Painting must lie inside outer frame'
points=np.concatenate([outline,hole]);n=len(outline);apex,ir,br,bl,il=range(n,n+5)
def arc(a,b):return list(range(a,b+1)) if a<=b else list(range(a,n))+list(range(b+1))
polygons=[arc(ls,rs)+[ir,apex,il],arc(rs,rb)+[br,ir],arc(rb,lb)+[bl,br],arc(lb,ls)+[il,bl]]
assert abs(sum(abs(area(points[p])) for p in polygons)-(area(outline)-abs(area(hole))))<1e-6
full=np.zeros(mask.shape,dtype='uint8');cv2.fillPoly(full,[raw],1)
simplified=np.zeros(mask.shape,dtype='uint8');cv2.fillPoly(simplified,[outline.astype('int32')],1)
silhouette_iou=float(np.count_nonzero(simplified&full)/np.count_nonzero(simplified|full));assert silhouette_iou>.99
frame=full.copy();cv2.fillPoly(frame,[hole.astype('int32')],0)
sh,sw=full.shape;gh,gw=gold.shape[:2]
hsv=cv2.cvtColor(gold,cv2.COLOR_RGB2HSV);native_outer=~((hsv[:,:,0]>=125)&(hsv[:,:,0]<=175)&(hsv[:,:,1]>20))
white=(gold.min(axis=2)>245).astype('uint8');count,labels,stats,_=cv2.connectedComponentsWithStats(white);opening=int(labels[1200,720]);assert opening>0
white=labels==opening
ny,nx=np.where(white);gy0,gy1=int(ny.min()),int(ny.max());gyshoulder=909
# Row-wise band fit: native texture pixels retain their facets; source outline/opening own the geometry.
mapx=np.zeros(full.shape,dtype='float32');mapy=np.zeros(full.shape,dtype='float32')
source_ys=[float(outline[:,1].min()),246.,1158.,2158.,float(outline[:,1].max())]
native_ys=[55.,float(gy0),float(gyshoulder),float(gy1),1715.]
for y in range(sh):
 sx=np.flatnonzero(full[y]);gy=float(np.interp(y,source_ys,native_ys));row=int(round(gy));gx=np.flatnonzero(native_outer[row]);wx=np.flatnonzero(white[row])
 if not len(sx) or not len(gx):continue
 sy0,sy1=float(sx[0]),float(sx[-1]);gx0,gx1=float(gx[0]+3),float(gx[-1]-3)
 if y>=246 and y<=2158:
  t=np.clip((y-246)/(1158-246),0,1);sleft=671+(241-671)*t;sright=671+(1090-671)*t
  if len(wx):gleft=float(wx[0]-3);gright=float(wx[-1]+3)
  else:gleft=gright=720.
 else:sleft=sright=671.;gleft=gright=720.
 # Source outline extrema and painting lip are the band ends. Avoid native matte/white lip samples.
 xs=np.arange(sw);left=xs<=sleft
 mapx[y,left]=np.interp(xs[left],[sy0,sleft],[gx0,gleft]);mapx[y,~left]=np.interp(xs[~left],[sright,sy1],[gright,gx1])
 valid=np.flatnonzero(cv2.erode((native_outer[row]&~white[row]).astype('uint8')[None,:],np.ones((1,5),dtype='uint8'))[0])
 assert len(valid)>0,(y,row)
 indices=np.searchsorted(valid,mapx[y]);lo=valid[np.clip(indices-1,0,len(valid)-1)];hi=valid[np.clip(indices,0,len(valid)-1)]
 mapx[y]=np.where(abs(mapx[y]-lo)<=abs(hi-mapx[y]),lo,hi);mapy[y]=row
fitted=cv2.remap(gold,mapx,mapy,cv2.INTER_NEAREST,borderMode=cv2.BORDER_REPLICATE)
fit_hsv=cv2.cvtColor(fitted,cv2.COLOR_RGB2HSV)
assert np.count_nonzero((fit_hsv[:,:,0]>=125)&(fit_hsv[:,:,0]<=175)&(fit_hsv[:,:,1]>20)&(frame>0))==0,'Mapped frame includes magenta'
rgba=np.dstack([fitted,frame*255]);rgba[frame==0,:3]=[162,124,55]
Image.fromarray(rgba).save(app/'trial/magdalene-frame-fitted.png')
# The painting is an untouched crop of official pixels, including its gilded painted apex.
box=(241,246,1091,2159);painting=original[box[1]:box[3],box[0]:box[2]]
Image.fromarray(painting).save(app/'trial/magdalene-painting-original-crop.png')
assert np.array_equal(np.array(Image.open(app/'trial/magdalene-painting-original-crop.png')),painting)
size=[.225,.495];centre=[(241+1090)/2,(246+2158)/2];scale=[size[0]/(1090-241),size[1]/(2158-246)]
world=[[(x-centre[0])*scale[0],(centre[1]-y)*scale[1]] for x,y in points]
outer_size=[float(np.ptp(outline[:,0])*scale[0]),float(np.ptp(outline[:,1])*scale[1])]
# ponytail: source front silhouette and native extruded ring; carved depth/back/metric placement need source validation.
record={'accession':'21.250','source':str(source.relative_to(app)),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'native':str(native.relative_to(app)),'native_sha256':hashlib.sha256(native.read_bytes()).hexdigest(),'source_size_px':[sw,sh],'points_px':points.tolist(),'points_m':world,'polygons':polygons,'loops':[list(range(n)),[n+i for i in range(4,-1,-1)]],'depth_m':.035,'depth_accepted':False,'outer_size_m':outer_size,'canvas_m':size,'painting_outline':((hole-[241,246])/[849,1912]).tolist(),'silhouette_iou':silhouette_iou,'assembly_checks':{'original_crop_pixels_equal':True,'painting_inside_frame':True,'no_native_matte_samples':True,'band_area_matches_ring':True},'source_band_area_px2':float(area(outline)-abs(area(hole))),'outline_vertices':n,'source_fit':'Source outline/opening; Muse row-wise bands, warm gold facets. Native original unchanged. Official dimensions provisionally interpreted as painted panel; pixel crop aspect retained.','accepted':False,'placement_m':[1.18,1.55,28.30],'placement_accepted':False}
(app/'magdalene-frame-source-fit.json').write_text(json.dumps(record,indent=2)+'\n')
print('Source profile:',n,'outline vertices,4 bands; framed size',outer_size,'; original panel pixels preserved')
