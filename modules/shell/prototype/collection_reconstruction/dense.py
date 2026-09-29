"""Bounded CUDA depth trial on a connected sparse component."""
import pathlib
import pycolmap
root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
run=root/'sfm-galleries-v3';output=root/'dense-connected-v1'
output.mkdir(exist_ok=True)
pycolmap.undistort_images(output,run/'sparse/3',run/'images',num_patch_match_src_images=6,
                         undistort_options=pycolmap.UndistortCameraOptions(max_image_size=640),num_threads=8)
o=pycolmap.PatchMatchOptions();o.gpu_index='0';o.max_image_size=640;o.num_samples=10;o.num_iterations=3;o.cache_size=2;o.num_threads=8
pycolmap.patch_match_stereo(output,options=o)
f=pycolmap.StereoFusionOptions();f.num_threads=8;f.cache_size=2
pycolmap.stereo_fusion(output/'fused.ply',output,options=f,output_type='ply')
print('DENSE COMPLETE',flush=True)
