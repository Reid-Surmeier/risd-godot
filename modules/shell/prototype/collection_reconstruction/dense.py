"""Bounded CUDA depth trial on a connected sparse component."""
import pathlib
import argparse
import pycolmap
root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
parser=argparse.ArgumentParser()
parser.add_argument('--run',default='sfm-galleries-v3')
parser.add_argument('--component',default='3')
parser.add_argument('--output',default='dense-connected-v1')
parser.add_argument('--size',type=int,default=640)
parser.add_argument('--image-list',type=pathlib.Path,help='Optional newline-separated registered views for a bounded depth trial')
args=parser.parse_args()
assert pycolmap.has_cuda, 'CUDA required for depth estimation'
run=root/args.run;output=root/args.output
output.mkdir(exist_ok=True)
selected=set(args.image_list.read_text().splitlines()) if args.image_list else set()
if args.image_list:
    original=pycolmap.Reconstruction(run/'sparse'/args.component)
    assert selected and selected <= {i.name for i in original.images.values() if i.has_pose}
pycolmap.undistort_images(output,run/'sparse'/args.component,run/'images',num_patch_match_src_images=6,
                         image_names=sorted(selected),
                         undistort_options=pycolmap.UndistortCameraOptions(max_image_size=args.size),num_threads=8)
if selected:
    # COLMAP retains the full sparse model when undistorting a subset. Auto source
    # selection otherwise requests bitmaps that were never exported.
    subset=pycolmap.Reconstruction(output/'sparse')
    for frame in {i.frame_id for i in subset.images.values() if i.name not in selected}:
        subset.deregister_frame(frame)
    subset.write(output/'sparse')
    checked=pycolmap.Reconstruction(output/'sparse')
    assert {i.name for i in checked.images.values()} == selected
    assert all((output/'images'/i.name).is_file() for i in checked.images.values())
o=pycolmap.PatchMatchOptions();o.gpu_index='0';o.max_image_size=args.size;o.num_samples=10;o.num_iterations=3;o.cache_size=2;o.num_threads=8
pycolmap.patch_match_stereo(output,options=o)
f=pycolmap.StereoFusionOptions();f.num_threads=8;f.cache_size=2
pycolmap.stereo_fusion(output/'fused.ply',output,options=f,output_type='ply')
print('DENSE COMPLETE',flush=True)
