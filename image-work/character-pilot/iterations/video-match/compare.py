"""Compare attributed short YouTube clips with native previews; no motion synthesis."""
from pathlib import Path
import json, subprocess, sys, tempfile
from PIL import Image, ImageDraw, ImageOps

HERE = Path(__file__).resolve().parent
version = sys.argv[1] if len(sys.argv) > 1 else 'v4'
assert version in ['v4', 'v5', 'v6']
reference = json.loads((HERE / 'youtube/youtube-comparison.json').read_text())
for view in ['front', 'profile']:
    window = next(w for w in reference['recommended_view_windows'] if w['name'] == view)
    start = window['absolute_seconds'][0]
    source = next((HERE / 'youtube').glob(view + '-*.mp4'))
    target = HERE.parent / f'video-match-{"game" if view == "front" else "profile"}-fast-{version}'
    assert (target / 'loop.mp4').is_file()
    poses = [p for p in reference['selected_frames'] if p['name'].startswith(view)]
    frames = []
    with tempfile.TemporaryDirectory(prefix='character-short-compare-') as scratch:
        path = Path(scratch)
        subprocess.run(['ffmpeg', '-v', 'error', '-i', str(source), '-frames:v', '24',
                        str(path / 'source-%03d.png')], check=True)
        subprocess.run(['ffmpeg', '-v', 'error', '-stream_loop', '-1', '-i', str(target / 'loop.mp4'),
                        '-frames:v', '24', str(path / 'target-%03d.png')], check=True)
        for index in range(24):
            absolute = start + index / 30
            before = max((p for p in poses if p['source_seconds'] <= absolute),
                         key=lambda p:p['source_seconds'], default=poses[0])
            after = min((p for p in poses if p['source_seconds'] >= absolute),
                        key=lambda p:p['source_seconds'], default=poses[-1])
            fraction = 0 if before == after else (absolute-before['source_seconds'])/(after['source_seconds']-before['source_seconds'])
            crop = [round(a+(b-a)*fraction) for a,b in zip(before['crop_xyxy_px'],after['crop_xyxy_px'])]
            left = ImageOps.pad(Image.open(path / f'source-{index+1:03d}.png').convert('RGB').crop(crop),(320,320),method=Image.Resampling.NEAREST,color='#18202b')
            right = ImageOps.pad(Image.open(path / f'target-{index+1:03d}.png').convert('RGB').crop((330,190,560,450)),(320,320),method=Image.Resampling.NEAREST,color='#18202b')
            frame = Image.new('RGB',(660,390),'#18202b')
            frame.paste(left,(5,35));frame.paste(right,(335,35));draw=ImageDraw.Draw(frame)
            draw.text((5,8),f'YouTube / Mutch Games / {absolute:.3f}s',fill='white')
            draw.text((335,8),f'Native {version}: game-camera {view}',fill='white')
            draw.text((5,360),'Tracked crops; unequal outfits. Source turns; phase is not verified.',fill='white')
            draw.text((5,376),'Both crops preserve aspect. Phase/yaw/scale are not fitted; no exact-fit proof.',fill='white')
            frame.save(path / f'comparison-{index:03d}.png');frames.append(frame)
        dest=HERE/f'youtube-{view}-{version}';dest.mkdir(exist_ok=True)
        subprocess.run(['ffmpeg','-v','error','-y','-framerate','30','-i',str(path/'comparison-%03d.png'),
                        '-c:v','libx264','-pix_fmt','yuv420p','-movflags','+faststart',str(dest/'comparison.mp4')],check=True)
        frames[0].save(dest/'comparison.gif',save_all=True,append_images=frames[2::2],duration=67,loop=0)
        strip=Image.new('RGB',(660,390*3))
        for row,index in enumerate([6,12,18]):strip.paste(frames[index],(0,390*row))
        strip.save(dest/'poses.png')
        (dest/'comparison.json').write_text(json.dumps({'source':reference['source_url'],'source_window':window,
            'target_config':str(target.relative_to(HERE.parent) / 'config.json'),'fps':30,'frames':24,
            'source_tracking':'manual crop anchors, linear interpolation; not anatomical landmark fit',
            'aspect_ratio_preserved':True,'resize':'uniform nearest-neighbor with letterboxing; no aspect correction of encoded source',
            'exact_fit':False,'cost_usd':0},indent=2)+'\n')
    print(dest)
