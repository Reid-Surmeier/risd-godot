"""Throwaway GPU survey; originals and reconstruction outputs stay outside Godot."""
import argparse
import json
import pathlib
import subprocess
import time

import pycolmap

ROOT = pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')


def extract():
    records = []
    for video in sorted((ROOT / 'verified').glob('*.MOV')):
        folder = ROOT / 'survey-2fps' / video.stem
        folder.mkdir(parents=True, exist_ok=True)
        if not (folder / 'complete.json').exists():
            command = ['ffmpeg', '-y', '-hide_banner', '-loglevel', 'error',
                       '-hwaccel', 'cuda', '-hwaccel_output_format', 'cuda',
                       '-noautorotate', '-i', str(video), '-an',
                       '-vf', 'scale_cuda=1280:720:format=yuv420p,hwdownload,format=yuv420p,fps=2',
                       '-q:v', '2', str(folder / '%06d.jpg')]
            subprocess.run(command, check=True)
            (folder / 'complete.json').write_text(json.dumps(command))
        frames = sorted(folder.glob('*.jpg'))
        records.append({'clip': video.stem, 'frames': len(frames), 'fps': 2,
                        'source_orientation': 'unmodified',
                        'held_out': [f.name for i, f in enumerate(frames) if i % 10 == 5]})
        print(video.name, len(frames), 'frames', flush=True)
    (ROOT / 'survey-2fps' / 'manifest.json').write_text(json.dumps(records, indent=2))


def reconstruct(name, clips, focal, all_pairs=False, resume=''):
    assert pycolmap.has_cuda, 'CUDA build required; no silent CPU extraction/matching fallback'
    run = ROOT / name
    images = run / 'images'
    images.mkdir(parents=True, exist_ok=True)
    names = []
    for clip in clips:
        target = images / clip
        target.mkdir(exist_ok=True)
        for i, source in enumerate(sorted((ROOT / 'survey-2fps' / clip).glob('*.jpg'))):
            if i % 10 == 5:
                continue  # Held-out views never enter feature extraction or fitting.
            link = target / source.name
            if not link.exists():
                link.symlink_to(source)
            names.append(f'{clip}/{source.name}')
    assert names, 'Extract reference frames first'
    database = run / 'database.db'
    start = time.time()
    extraction = pycolmap.FeatureExtractionOptions()
    extraction.num_threads = 8
    extraction.gpu_index = '0'
    extraction.sift.max_num_features = 8192
    reader = pycolmap.ImageReaderOptions(camera_model='SIMPLE_RADIAL')
    if focal:
        reader.camera_params = f'{focal},640,360,0'
        if database.exists():
            with pycolmap.Database.open(database) as db:
                for camera in db.read_all_cameras():
                    camera.params = [focal, 640, 360, 0]
                    camera.has_prior_focal_length = True
                    db.update_camera(camera)
    pycolmap.extract_features(database, images, camera_mode=pycolmap.CameraMode.PER_FOLDER,
                              reader_options=reader,
                              extraction_options=extraction, device=pycolmap.Device.cuda)
    matching = pycolmap.FeatureMatchingOptions()
    matching.num_threads = 8
    matching.gpu_index = '0'
    if all_pairs:
        pycolmap.match_exhaustive(database, matching_options=matching, device=pycolmap.Device.cuda)
    pycolmap.match_sequential(database, matching_options=matching,
                             pairing_options=pycolmap.SequentialPairingOptions(overlap=12),
                             device=pycolmap.Device.cuda)
    # Revisit across clips: coarse keyframes, then densify genuine cross-clip matches.
    keys = [n for n in names if int(pathlib.Path(n).stem) % 10 == 1]
    pairs = run / 'cross-clip-pairs.txt'
    pairs.write_text(''.join(f'{a} {b}\n' for i, a in enumerate(keys) for b in keys[i+1:]
                            if a.split('/')[0] != b.split('/')[0]))
    if pairs.stat().st_size:
        pycolmap.match_image_pairs(database, matching_options=matching,
                                  pairing_options=pycolmap.ImportedPairingOptions(match_list_path=pairs),
                                  device=pycolmap.Device.cuda)
    options = pycolmap.IncrementalPipelineOptions()
    options.num_threads = 8
    options.ba_use_gpu = True
    options.ba_gpu_index = '0'
    options.random_seed = 182
    options.min_model_size = 15
    options.max_num_models = 15
    sparse = run / 'sparse'
    sparse.mkdir(exist_ok=True)
    options.snapshot_path = str(run / 'snapshots')
    (run / 'snapshots').mkdir(exist_ok=True)
    options.snapshot_frames_freq = 100
    models = pycolmap.incremental_mapping(database, images, sparse, options=options, input_path=resume)
    result = {'clips': clips, 'input_images': len(names), 'seconds': time.time()-start,
              'pycolmap': pycolmap.__version__, 'cuda': pycolmap.has_cuda,
              'all_pairs': all_pairs, 'resumed_from': resume,
              'metric_scale': 'unknown: monocular arbitrary units', 'models': []}
    for index, model in models.items():
        model_path = sparse / str(index)
        model_path.mkdir(exist_ok=True)
        model.write(model_path)
        model.export_PLY(str(sparse / f'{index}.ply'))
        registered = sorted(image.name for image in model.images.values() if image.has_pose)
        result['models'].append({'id': index, 'images': model.num_reg_images(),
                                 'points': model.num_points3D(),
                                 'mean_reprojection_error': model.compute_mean_reprojection_error(),
                                 'registered': registered})
    (run / 'result.json').write_text(json.dumps(result, indent=2))
    print(json.dumps({**result, 'models': [{k:v for k,v in m.items() if k != 'registered'}
                                         for m in result['models']]}, indent=2), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('stage', choices=['extract', 'reconstruct'])
    parser.add_argument('--name', default='sfm-galleries-v1')
    parser.add_argument('--focal', type=float, help='Measured preliminary focal estimate, at 1280 px width')
    parser.add_argument('--all-pairs', action='store_true')
    parser.add_argument('--resume', default='', help='Existing sparse component to extend')
    parser.add_argument('--clips', nargs='+', default=['IMG_6383', 'IMG_6384', 'IMG_6385', 'IMG_6386'])
    args = parser.parse_args()
    extract() if args.stage == 'extract' else reconstruct(args.name, args.clips, args.focal, args.all_pairs, args.resume)
