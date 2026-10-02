"""Retry doorway growth with video intrinsics supported by the larger room reconstruction."""
import json
import pathlib
import shutil
import pycolmap

root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
source=root/'sfm-doorway-v1';out=root/'sfm-calibrated-doorway-v1';out.mkdir(exist_ok=True)
database=out/'database.db'
if not database.exists():shutil.copyfile(source/'database.db',database)
if not (out/'images').exists():(out/'images').symlink_to(source/'images',target_is_directory=True)
seed=pycolmap.Reconstruction(root/'sfm-connected-v4/sparse/0')
reference=pycolmap.Reconstruction(root/'sfm-connected-v4/sparse/5')
old=seed.cameras[5].params.tolist();new=reference.cameras[5].params.tolist()
seed.cameras[5].params=new
with pycolmap.Database.open(database) as db:
    for camera in seed.cameras.values():db.update_camera(camera)
calibration=out/'seed';calibration.mkdir(exist_ok=True);seed.write(calibration)
(out/'calibration.json').write_text(json.dumps(dict(camera=5,clip='IMG_6380',old_params=old,new_params=new,
 source='sfm-connected-v4/sparse/5',reason='The main model estimates this video camera from two frames; the decorative model uses 225 frames. Freeze intrinsics for this bounded comparison.',
 caveat='Not external camera calibration; validate geometry and held-out views.'),indent=2))
options=pycolmap.IncrementalPipelineOptions();options.num_threads=8;options.ba_use_gpu=True;options.ba_gpu_index='0';options.random_seed=182;options.max_num_models=1
options.ba_refine_focal_length=False;options.ba_refine_extra_params=False
sparse=out/'sparse';sparse.mkdir(exist_ok=True)
models=pycolmap.incremental_mapping(database,out/'images',sparse,options=options,input_path=calibration)
result=[]
for index,model in models.items():
    folder=sparse/str(index);folder.mkdir(exist_ok=True);model.write(folder)
    result.append(dict(component=index,images=model.num_reg_images(),points=model.num_points3D(),mean_reprojection_error=model.compute_mean_reprojection_error(),registered=sorted(i.name for i in model.images.values())))
(out/'result.json').write_text(json.dumps(result,indent=2))
print(json.dumps([{k:v for k,v in x.items() if k!='registered'} for x in result],indent=2))
