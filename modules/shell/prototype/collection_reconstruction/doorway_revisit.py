"""GPU re-sampling around the observed exit; extend the room without guessing a join."""
import json
import pathlib
import shutil
import subprocess
import pycolmap

root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
base=root/'sfm-connected-v4';out=root/'sfm-doorway-v1';images=out/'images'
images.mkdir(parents=True,exist_ok=True)
for folder in (base/'images').iterdir():
    if not (images/folder.name).exists():(images/folder.name).symlink_to(folder,target_is_directory=True)
new=images/'IMG_6380_exit6fps';new.mkdir(exist_ok=True)
if not (new/'complete.json').exists():
    command=['ffmpeg','-y','-v','error','-hwaccel','cuda','-hwaccel_output_format','cuda','-noautorotate','-ss','250','-i',str(root/'verified/IMG_6380.MOV'),'-t','11',
        '-vf','scale_cuda=1280:720:format=yuv420p,hwdownload,format=yuv420p,fps=6','-q:v','2',str(new/'%06d.jpg')]
    subprocess.run(command,check=True);(new/'complete.json').write_text(json.dumps(command))
# Exclude samples near the original held-out times 252.5 and 257.5 seconds.
names=[f'IMG_6380_exit6fps/{p.name}' for p in sorted(new.glob('*.jpg')) if all(abs(250+(int(p.stem)-1)/6-t)>.2 for t in [252.5,257.5])]
database=out/'database.db'
if not database.exists():shutil.copyfile(base/'database.db',database)
seed=pycolmap.Reconstruction(base/'sparse/5');camera=next(seed.cameras[i.camera_id] for i in seed.images.values() if i.name.startswith('IMG_6380/'))
with pycolmap.Database.open(database) as db:db.update_camera(camera)
reader=pycolmap.ImageReaderOptions();reader.existing_camera_id=camera.camera_id
extract=pycolmap.FeatureExtractionOptions();extract.gpu_index='0';extract.num_threads=8;extract.sift.max_num_features=8192
assert pycolmap.has_cuda
pycolmap.extract_features(database,images,image_names=names,reader_options=reader,extraction_options=extract,device=pycolmap.Device.cuda)
other=pycolmap.Reconstruction(base/'sparse/0')
refs=sorted({i.name for model in [seed,other] for i in model.images.values()})
pairs=out/'pairs.txt';pairs.write_text(''.join(f'{a} {b}\n' for a in names for b in refs)+''.join(f'{a} {b}\n' for i,a in enumerate(names) for b in names[i+1:]))
matching=pycolmap.FeatureMatchingOptions();matching.gpu_index='0';matching.num_threads=8
pycolmap.match_image_pairs(database,matching_options=matching,pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pairs),device=pycolmap.Device.cuda)
options=pycolmap.IncrementalPipelineOptions();options.num_threads=8;options.ba_use_gpu=True;options.ba_gpu_index='0';options.random_seed=182;options.max_num_models=1
sparse=out/'sparse';sparse.mkdir(exist_ok=True)
models=pycolmap.incremental_mapping(database,images,sparse,options=options,input_path=base/'sparse/5')
result=[]
for index,model in models.items():
    path=sparse/str(index);path.mkdir(exist_ok=True);model.write(path)
    registered=sorted(i.name for i in model.images.values())
    result.append(dict(component=index,images=model.num_reg_images(),points=model.num_points3D(),mean_reprojection_error=model.compute_mean_reprojection_error(),registered=registered,
        additional_samples=len(names),resumed_from='sfm-connected-v4/sparse/5',independent_validation=False))
(out/'result.json').write_text(json.dumps(result,indent=2))
print(json.dumps([{k:v for k,v in x.items() if k!='registered'} for x in result],indent=2))
