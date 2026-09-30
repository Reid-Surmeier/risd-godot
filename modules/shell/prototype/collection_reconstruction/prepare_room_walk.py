"""#182 observed two-room route, with explicitly provisional collision hypotheses."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

import numpy as np
import pycolmap
from PIL import Image, ImageDraw
from measurements import raw

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
parser.add_argument('--source', default='sfm-strict-doorway-v1')
parser.add_argument('--anchor', default='bookcase-extrema-v2')
parser.add_argument('--capture-poses', type=Path, help='Independent capture pose diagnostics; no query geometry enters mapping')
parser.add_argument('--dense-context', action='store_true', help='Reproject cached observed depth as visual context only')
args = parser.parse_args()
out = args.output
out.mkdir(parents=True, exist_ok=False)
repo = Path(__file__).resolve().parents[4]
source = Path(__file__).resolve().parent
scale_path = ROOT/args.anchor/'result.json'
anchor = json.loads(scale_path.read_text())
basis = np.array(anchor['basis_rows'])
origin = np.array(anchor['origin_world'])
scale = anchor['height_scale_m_per_unit']
sparse = ROOT/args.source/'sparse/0'
inputs = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in [scale_path, *sparse.glob('*.bin')]}
model = pycolmap.Reconstruction(sparse)
views = {v.name: v for v in model.images.values()}
point_ids = np.array(list(model.points3D))
points = list(model.points3D.values())
world = np.array([p.xyz for p in points])
colors = np.array([p.color for p in points])
xyz = (world-origin)@basis.T*scale
# Frozen source-reviewed wood-floor candidates exclude white platforms and wall bases.
ids = set()
for number in [245, 251, 263, 273, 283, 313, 323, 343, 373, 375, 377, 443, 453, 505, 513, 519]:
    name = f'IMG_6380/{number:06}.jpg'
    if name in views:
        ids.update(p.point3D_id for p in views[name].points2D if p.has_point3D() and p.xy[0] > 930)
mask = np.isin(point_ids, list(ids))
mask &= (colors[:, 0] > colors[:, 1]+8) & (colors[:, 1] > colors[:, 2]+8)
mask &= (xyz[:, 1] < -.1) & (xyz[:, 1] > -1) & (xyz[:, 2] > 1) & (xyz[:, 2] < 6)
fit = xyz[mask & (point_ids % 2 == 1)]
test = xyz[mask & (point_ids % 2 == 0)]
assert len(fit) >= 30 and len(test) >= 30
rng = np.random.default_rng(182)
best = np.zeros(len(fit), dtype=bool)
for _ in range(1000):
    triangle = fit[rng.choice(len(fit), 3, replace=False)]
    normal = np.cross(triangle[1]-triangle[0], triangle[2]-triangle[0])
    length = np.linalg.norm(normal)
    if length < 1e-9:
        continue
    normal /= length
    if abs(normal[1]) < .9:
        continue
    keep = abs((fit-triangle[0])@normal) < .025
    if keep.sum() > best.sum():
        best = keep
assert best.sum() >= 30
center = fit[best].mean(0)
normal = np.linalg.svd(fit[best]-center)[2][-1]
if normal[1] < 0:
    normal = -normal
up = basis.T@normal
across = np.array(anchor['points_world']['top_right'])-anchor['points_world']['top_left']
across -= up*(across@up)
across /= np.linalg.norm(across)
basis = np.array([across, up, np.cross(across, up)])
# Height is still a candidate scale: front rail may sit below the catalogue's rear rail.
scale = 1.515/np.mean([(np.array(anchor['points_world'][a])-anchor['points_world'][b])@up
    for a, b in [('top_left', 'foot_left'), ('top_right', 'foot_right')]])
floor_center = center@np.array(anchor['basis_rows'])/anchor['height_scale_m_per_unit']+origin
origin -= up*((origin-floor_center)@up)
xyz = (world-origin)@basis.T*scale
# The left pixel is the open leaf free edge, not a stationary jamb or surveyed floor contact.
# Rays intersect the candidate floor only to place conservative clearance proxies.
name = 'IMG_6384/000207.jpg'
if name in views:
    view = views[name]
    camera = model.cameras[view.camera_id]
    pose = view.cam_from_world()
else:
    assert args.capture_poses, 'An excluded capture requires a separately supported pose'
    capture = json.loads(args.capture_poses.read_text())
    row = next(r for r in capture['rows'] if r['image']==name)
    assert row['supported'] and capture['whole_capture_excluded_from_mapping']
    camera = pycolmap.Camera(row['camera'])
    matrix = np.array(row['cam_from_world'])
    pose = pycolmap.Rigid3d(pycolmap.Rotation3d(matrix[:,:3]),matrix[:,3])
    inputs[str(args.capture_poses)] = hashlib.sha256(args.capture_poses.read_bytes()).hexdigest()
pixels = [[176, 921], [461, 1073]]
rays = np.c_[camera.cam_from_img(raw(pixels)), np.ones(2)]@pose.rotation.matrix()
eye = pose.inverse().translation
distances = ((origin-eye)@up)/(rays@up)
assert np.all(distances > 0)
contacts = (eye+rays*distances[:, None]-origin)@basis.T*scale
left, right = np.sort(contacts[:, 0])
assert 1 < right-left < 3
z0 = float(contacts[:, 2].mean())
mid = float((left+right)/2)
xyz[:, 2] -= z0
# ponytail: flat route floor and rectangular jamb proxies; replace after held-out floor/door acceptance.
patches = [dict(label='decorative room study support', color='81735c', vertices=[[-1.9,0,1-z0],[2.8,0,1-z0],[2.8,0,-.2],[-1.9,0,-.2]]),
    dict(label='uncertain threshold', color='ad8952', vertices=[[left,0,-.2],[right,0,-.2],[right,0,.2],[left,0,.2]]),
    dict(label='painting gallery study support', color='7d7d72', vertices=[[-2,0,.2],[3.2,0,.2],[3.2,0,12-z0],[-2,0,12-z0]])]
boxes = [dict(center=[left-.11,1.6,0],size=[.22,3.2,.4]), dict(center=[right+.11,1.6,0],size=[.22,3.2,.4])]
trials = [['forward',[mid,.25,1.2],[mid,0,-1.2],False],['reverse',[mid,.25,-1.2],[mid,0,1.2],False],
    ['left_blocked',[left-.1,.25,.75],[left-.1,0,-.5],True],
    ['right_blocked',[right+.1,.25,.75],[right+.1,0,-.5],True],
    ['decorative_room',[mid,.25,-1.2],[mid,0,-3.2],False],
    ['painting_gallery',[mid,.25,1.2],[mid,0,3.2],False]]
geometry = dict(patches=patches, boxes=boxes, trials=trials, trial_seconds=3.5, start=[mid,.25,1.2],
    caption='Collection two-room route · WASD move · Space reset\nObserved sparse context; gold threshold / door-clearance proxies are provisional.\nFloor edges are study limits. Full room walls and bake remain unfinished.\n',
    navigation_accepted=False, scale_accepted=False, source_sha256=inputs,
    scale_m_per_unit=scale, basis_rows=basis.tolist(), floor_origin_world=origin.tolist(), source_model=args.source,
    doorway_candidate=dict(source=name,pixels=pixels,floor_ray_intersections_local_m=contacts.tolist(),pixel_roles=['open leaf lower free edge, not a stationary jamb','unverified right opening edge'],z_origin_m=z0),
    floor=dict(candidate_point_ids=point_ids[mask].tolist(),fit_odd_points=len(fit),fit_support=int(best.sum()),unused_even_points=len(test),
        unused_residual_p50_p90_m=np.percentile(abs((test-center)@normal),[50,90]).tolist()),
    caveat='Observed decorative room and painting gallery share this visible opening; corridor opening is distinct. '
           'Provisional scale from bookcase front endpoints. Split wood points support floor orientation locally; '
           'flat floor extension, threshold levels and ray-derived clearance boxes are hypotheses. Left input is an open leaf edge, not fixed architecture. '
           'No full room extents, unseen connectors, physical collision acceptance or production integration.')
(out/'geometry.json').write_text(json.dumps(geometry,indent=2)+'\n')
sparse_xyz, sparse_colors = xyz.copy(), colors.copy()
if args.dense_context:
    # Similarity fits odd-numbered source cameras; even camera centres only check it.
    dense_root = ROOT/'dense-expanded-v1'
    old_model = pycolmap.Reconstruction(dense_root/'sparse')
    old_views = {v.name: v for v in old_model.images.values()}
    names = sorted(n for n in set(old_views)&set(views) if n.startswith('IMG_6380/'))
    old_centres = np.array([old_views[n].projection_center() for n in names])
    new_centres = np.array([views[n].projection_center() for n in names])
    train = np.array([int(Path(n).stem)%2==1 for n in names])
    a, b = old_centres[train].mean(0), new_centres[train].mean(0)
    u, singular, vt = np.linalg.svd((new_centres[train]-b).T@(old_centres[train]-a)/train.sum())
    signs = np.ones(3)
    signs[-1] = np.linalg.det(u@vt)
    rotation = u@np.diag(signs)@vt
    factor = np.sum(singular*signs)/np.mean(np.sum((old_centres[train]-a)**2,axis=1))
    translation = b-factor*rotation@a
    residual = np.linalg.norm(old_centres*factor@rotation.T+translation-new_centres,axis=1)*scale
    assert np.percentile(residual[~train],95)<.03, 'Reject visual-cloud transform above 3 provisional cm'
    cloud = pycolmap.Reconstruction()
    cloud.import_PLY(str(dense_root/'fused.ply'))
    cloud_points = list(cloud.points3D.values())
    dense_world = np.array([p.xyz for p in cloud_points])*factor@rotation.T+translation
    xyz = (dense_world-origin)@basis.T*scale
    xyz[:,2] -= z0
    colors = np.array([p.color for p in cloud_points])
    # Keep at most one point per 15mm visual voxel; sparse/depth gaps remain visible.
    _, indices = np.unique(np.floor(xyz/.015).astype(int),axis=0,return_index=True)
    xyz, colors = np.r_[xyz[indices], sparse_xyz], np.r_[colors[indices], sparse_colors]
    geometry['visual_cloud_alignment'] = dict(fit_views=int(train.sum()),unused_views=int((~train).sum()),
        unused_camera_residual_p50_p95_m=np.percentile(residual[~train],[50,95]).tolist(),
        similarity_scale=factor,rotation=rotation.tolist(),translation=translation.tolist(),
        caveat='Cached older dense reconstruction is visual context only; it includes prior correlated '
               'training views and must not enter held-out geometry checks or physical collision acceptance.')
    for path in [dense_root/'fused.ply',*(dense_root/'sparse').glob('*.bin')]:
        inputs[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
    (out/'geometry.json').write_text(json.dumps(geometry,indent=2)+'\n')
# Restrict visual context to the two room study areas; never turn sparse gaps into walls.
visible = (xyz[:,0]>-3.5)&(xyz[:,0]<4)&(xyz[:,1]>-.2)&(xyz[:,1]<4)&(xyz[:,2]>-z0)&(xyz[:,2]<13-z0)
np.c_[xyz[visible],colors[visible]/255].astype('<f4').tofile(out/'points.bin')
for filename in ['doorway_walk.gd','doorway_walk.tscn']:
    shutil.copyfile(source/filename,out/filename)
for relative in ['modules/shell/prototype/gallery_walk4/rig/visitor.gd','modules/shell/prototype/gallery_walk4/identity/visitor_identity.glb']:
    target=out/relative
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(repo/relative,target)
(out/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Collection room route study"\nrun/main_scene="res://doorway_walk.tscn"\n[display]\nwindow/size/viewport_width=1100\nwindow/size/viewport_height=760\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
(out/'export_presets.cfg').write_text('[preset.0]\nname="Web"\nplatform="Web"\nrunnable=true\nexport_filter="all_resources"\ninclude_filter="geometry.json,points.bin"\nexclude_filter="web/*,evidence/*"\nexport_path="web/index.html"\n[preset.0.options]\nvariant/thread_support=false\nhtml/export_icon=false\nhtml/canvas_resize_policy=2\n')
im=Image.new('RGB',(1100,1100),'#202934');draw=ImageDraw.Draw(im)
def pixel(p):return (int(370+p[0]*65),int(520+p[2]*65))
for patch in patches:
    draw.polygon([pixel(p) for p in patch['vertices']],fill='#'+patch['color'],outline='white')
for p,c in zip(xyz[visible],colors[visible]):
    draw.point(pixel(p),fill=tuple(c))
for box in boxes:
    x,y=pixel(box['center']);draw.rectangle((x-8,y-13,x+8,y+13),fill='white')
draw.text((20,20),'Observed two-room route. Floor edges are study limits, NOT complete museum walls.',fill='white')
draw.text((20,40),'Scale/floors/clearance boxes are hypotheses. Left pixel is an open leaf edge.',fill='white')
im.save(out/'plan.png')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in inputs.items())
assert np.allclose(basis@basis.T,np.eye(3)) and np.isfinite(xyz).all()
print(json.dumps(dict(floor={k:v for k,v in geometry['floor'].items() if k!='candidate_point_ids'},doorway=geometry['doorway_candidate'],visual_points=int(visible.sum()),scale=scale)))
