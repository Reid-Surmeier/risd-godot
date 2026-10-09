"""Check every net/axe surface sample against the actual skinned head, not a bounding box."""
import json,sys,numpy as np
from pathlib import Path
p=Path(sys.argv[1]);d=p/'tool-clearance';s=json.loads((d/'static.json').read_text());rows=json.loads((d/'index.json').read_text());v=s['vertex_count']
raw=np.memmap(d/'poses.bin',dtype=np.float32,mode='r');tri=np.array(s['indices']).reshape(-1,3)
head=np.array([sum(g.get(n,0) for n in ['Head','neck','head_end','headfront'])>.9 for g in s['groups']]);faces=tri[head[tri].all(1)]
def axis_hits(P, X, F, axis):
    a, b, c = X[F[:,0]], X[F[:,1]], X[F[:,2]]; o = [i for i in range(3) if i != axis]
    A, v0, v1 = a[:,o], c[:,o]-a[:,o], b[:,o]-a[:,o]
    d00=(v0*v0).sum(1); d01=(v0*v1).sum(1); d11=(v1*v1).sum(1); den=d00*d11-d01*d01; ok=np.abs(den)>1e-12
    A,v0,v1,d00,d01,d11,den = A[ok],v0[ok],v1[ok],d00[ok],d01[ok],d11[ok],den[ok]; a1,b1,c1 = a[ok,axis],b[ok,axis],c[ok,axis]
    hi=np.full(len(P),np.nan); lo=np.full(len(P),np.nan)
    for s in range(0,len(P),256):
        p=P[s:s+256][:,o]; v2=p[:,None,:]-A[None]; d20=(v2*v0[None]).sum(2); d21=(v2*v1[None]).sum(2)
        u=(d11*d20-d01*d21)/den; v=(d00*d21-d01*d20)/den; ins=(u>=-1e-9)&(v>=-1e-9)&(u+v<=1+1e-9); h=a1+u*(c1-a1)+v*(b1-a1)
        hh=np.where(ins,h,-np.inf).max(1); ll=np.where(ins,h,np.inf).min(1)
        hi[s:s+256]=np.where(np.isfinite(hh),hh,np.nan); lo[s:s+256]=np.where(np.isfinite(ll),ll,np.nan)
    return hi, lo
def inside4(P, X, F):
    depth=np.full(len(P),np.inf)
    for axis in (0,2):
        hi,lo=axis_hits(P,X,F,axis); d=np.minimum(hi-P[:,axis],P[:,axis]-lo); depth=np.minimum(depth,np.where(np.isnan(d),-np.inf,d))
    return depth
def mind(P,Q):
    best=np.inf
    for s in range(0,len(P),512): best=min(best,float(np.sqrt(((P[s:s+512,None,:]-Q[None])**2).sum(2)).min()))
    return best

def surface_distance(P,X,F):
    a,b,c=X[F[:,0]],X[F[:,1]],X[F[:,2]];ab=b-a;ac=c-a;n=np.cross(ab,ac);nn=(n*n).sum(1)
    best=np.inf
    for start in range(0,len(P),64):
        points=P[start:start+64,None,:];ap=points-a
        dot=(ap*n).sum(2);project=ap-dot[:,:,None]*n/np.maximum(nn,1e-20)[None,:,None]
        aa=(ab*ab).sum(1);bb=(ac*ac).sum(1);cc=(ab*ac).sum(1);den=aa*bb-cc*cc
        u=((project*ab).sum(2)*bb-(project*ac).sum(2)*cc)/np.maximum(den,1e-20)
        w=((project*ac).sum(2)*aa-(project*ab).sum(2)*cc)/np.maximum(den,1e-20)
        dist=np.where((u>=0)&(w>=0)&(u+w<=1)&(nn>1e-20),dot*dot/np.maximum(nn,1e-20),np.inf)
        for x,y in [(a,b),(b,c),(c,a)]:
            edge=y-x;q=points-x;t=np.clip((q*edge).sum(2)/np.maximum((edge*edge).sum(1),1e-20),0,1)
            dist=np.minimum(dist,((q-t[:,:,None]*edge)**2).sum(2))
        best=min(best,float(np.sqrt(dist.min())))
    return best
body=np.array([sum(g.get(n,0) for n in ['Hips','Spine','Spine01','Spine02','LeftUpLeg','RightUpLeg'])>.5 for g in s['groups']]);body_faces=tri[body[tri].all(1)]
arms=np.array([sum(g.get(n,0) for n in ['LeftForeArm','LeftHand','RightForeArm','RightHand'])>.9 for g in s['groups']]);regrip=[];last_hand={}
out=[]
for r in rows:
    x=np.array(raw[r['offset']//4:r['offset']//4+v*3]).reshape(v,3)
    if r['label'].startswith('regrip_'):
        points=x[arms];lo=x[body].min(0);hi=x[body].max(0)
        candidates=points[((points>=lo-.001)&(points<=hi+.001)).all(1)]
        inside=int((inside4(candidates,x,body_faces)>.001).sum()) if len(candidates) else 0
        hand=np.array(r['left_hand']);step=float(np.linalg.norm(hand-np.array(r['left_before'])))
        last_hand[r['label']]=hand;regrip.append({'scenario':r['label'],'tick':r['tick'],'inside':inside,'hand_step':step})
        continue
    for mesh,pts in r['pts'].items():
        points=np.array(pts);depth=inside4(points,x,faces);gap=surface_distance(points,x,faces)
        out.append({'scenario':r['label'],'tick':r['tick'],'mesh':mesh,'inside':int((depth>.001).sum()),'gap':gap})
receipt={'head_test_poses':len(rows)-len(regrip),'regrip_poses':len(regrip),'regrip_scenarios':len(last_hand),'maximum_regrip_hand_step':max(r['hand_step'] for r in regrip),'regrip_failures':[r for r in regrip if r['inside'] or r['hand_step']>.06],'poses':len(rows),'surface_queries':len(out),'minimum_gap':min(r['gap'] for r in out),'inside_queries':sum(r['inside']>0 for r in out),'failures':[r for r in out if r['inside']>0 or r['gap']<.01]}
(p/'tool-clearance-check.json').write_text(json.dumps(receipt,indent=2)+'\n')
assert not receipt['failures'] and not receipt['regrip_failures'] and receipt['regrip_scenarios']==48 and receipt['regrip_poses']==1920,receipt
print('PASS skinned head / actual tool surfaces',receipt)
