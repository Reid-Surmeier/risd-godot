"""Metric rectification of a wall plane from one painting.
rect.py FRAME CATALOGUE W_m H_m OUT [--crop x0,y0,x1,y1] [--win xmin,xmax,ymin,ymax] [--ppm 400] [--grid 0.1]
The catalogue crop (default: whole image) is taken to be the canvas, W_m x H_m. Window in metres relative
to the canvas centre (x right, y up). Prints inliers; writes OUT (rectified, with a metre grid) and OUT.json (H).
"""
import sys, json
import numpy as np, cv2
a=sys.argv[1:]
def opt(name,default=None):
    if name in a:
        i=a.index(name); v=a[i+1]; del a[i:i+2]; return v
    return default
crop=opt('--crop'); win=opt('--win','-1.5,1.5,-2.2,1.2'); ppm=float(opt('--ppm','400')); grid=float(opt('--grid','0.1'))
focal=opt('--focal')
nogrid='--nogrid' in a
if nogrid: a.remove('--nogrid')
frame_path,cat_path,W,H,out=a[0],a[1],float(a[2]),float(a[3]),a[4]
frame=cv2.imread(frame_path); cat=cv2.imread(cat_path)
if crop:
    x0,y0,x1,y1=[int(v) for v in crop.split(',')]; cat=cat[y0:y1,x0:x1]
# scale catalogue to roughly the footage resolution of the canvas (helps matching)
best=None
for target in [260,400,600,900]:
    s=target/cat.shape[1]
    c=cv2.resize(cat,None,fx=s,fy=s,interpolation=cv2.INTER_AREA)
    c=cv2.GaussianBlur(c,(0,0),1.2)
    sift=cv2.SIFT_create(nfeatures=6000,contrastThreshold=0.01)
    k1,d1=sift.detectAndCompute(cv2.cvtColor(c,cv2.COLOR_BGR2GRAY),None)
    k2,d2=sift.detectAndCompute(cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY),None)
    if d1 is None or d2 is None: continue
    m=cv2.BFMatcher().knnMatch(d1,d2,k=2)
    good=[p[0] for p in m if len(p)==2 and p[0].distance<0.8*p[1].distance]
    if len(good)<8: continue
    src=np.float32([k1[g.queryIdx].pt for g in good])/s
    dst=np.float32([k2[g.trainIdx].pt for g in good])
    Hm,mask=cv2.findHomography(src,dst,cv2.RANSAC,4.0)
    if Hm is None: continue
    n=int(mask.sum())
    if best is None or n>best[0]: best=(n,Hm,target,len(good),src[mask.ravel()==1],dst[mask.ravel()==1])
if best is None: print('NO MATCH'); sys.exit(1)
n,Hm,target,ng,isrc,idst=best
ch,cw=cat.shape[:2]
# metres -> catalogue px:  u=(X/W+0.5)*cw, v=(0.5-Y/H)*ch
M=np.array([[cw/W,0,cw/2],[0,-ch/H,ch/2],[0,0,1]],dtype=float)
xmin,xmax,ymin,ymax=[float(v) for v in win.split(',')]
# output px -> metres: X=xmin+px/ppm, Y=ymax-py/ppm
P=np.array([[1/ppm,0,xmin],[0,-1/ppm,ymax],[0,0,1]],dtype=float)
if focal:
    f=float(focal); fh,fw=frame.shape[:2]
    K=np.array([[f,0,fw/2],[0,f,fh/2],[0,0,1]],dtype=float)
    obj=np.zeros((len(isrc),3)); obj[:,0]=(isrc[:,0]/cw-0.5)*W; obj[:,1]=(0.5-isrc[:,1]/ch)*H
    ok,rvec,tvec=cv2.solvePnP(obj,idst.astype(float),K,None,flags=cv2.SOLVEPNP_ITERATIVE)
    R,_=cv2.Rodrigues(rvec)
    Hp=K@np.column_stack([R[:,0],R[:,1],tvec.ravel()])   # plane metres -> frame px
    proj=(Hp@np.column_stack([obj[:,0],obj[:,1],np.ones(len(obj))]).T).T; proj=proj[:,:2]/proj[:,2:3]
    err=np.sqrt(((proj-idst)**2).sum(1)).mean()
    cam=(-R.T@tvec).ravel()
    print('pnp f=%g reproj=%.2fpx camera at plane coords x=%.2f y=%.2f dist=%.2f m'%(f,err,cam[0],cam[1],abs(cam[2])))
    T=Hp@P
else:
    T=Hm@M@P   # output px -> frame px
ow,oh=int(round((xmax-xmin)*ppm)),int(round((ymax-ymin)*ppm))
rect=cv2.warpPerspective(frame,T,(ow,oh),flags=cv2.INTER_LINEAR|cv2.WARP_INVERSE_MAP,borderValue=(40,40,40))
clean=rect.copy()
if not nogrid:
    k=0
    x=np.ceil(xmin/grid)*grid
    while x<=xmax+1e-9:
        px=int(round((x-xmin)*ppm)); major=abs(x/0.5-round(x/0.5))<1e-6
        cv2.line(rect,(px,0),(px,oh-1),(0,0,255) if major else (0,200,255),1)
        if major: cv2.putText(rect,'%.1f'%x,(px+2,12),cv2.FONT_HERSHEY_SIMPLEX,0.4,(0,0,255),1)
        x+=grid
    y=np.ceil(ymin/grid)*grid
    while y<=ymax+1e-9:
        py=int(round((ymax-y)*ppm)); major=abs(y/0.5-round(y/0.5))<1e-6
        cv2.line(rect,(0,py),(ow-1,py),(0,0,255) if major else (0,200,255),1)
        if major: cv2.putText(rect,'%.1f'%y,(2,py-2),cv2.FONT_HERSHEY_SIMPLEX,0.4,(0,0,255),1)
        y+=grid
cv2.imwrite(out,rect); cv2.imwrite(out.replace('.png','-clean.png'),clean)
json.dump({'frame':frame_path,'catalogue':cat_path,'crop':crop,'canvas_m':[W,H],'H_cat_to_frame':Hm.tolist(),'inliers':n,'matches':ng,'cat_scale_px':target,'win':[xmin,xmax,ymin,ymax],'ppm':ppm},open(out.replace('.png','.json'),'w'))
# canvas corners in frame px, and canvas px size (resolution of the source)
cor=cv2.perspectiveTransform(np.float32([[[0,0],[cw,0],[cw,ch],[0,ch]]]),Hm)[0]
print('inliers',n,'of',ng,'cat width',target,'canvas px in frame: w=%.0f h=%.0f'%(np.linalg.norm(cor[1]-cor[0]),np.linalg.norm(cor[3]-cor[0])),'->',out,rect.shape[1],'x',rect.shape[0])
