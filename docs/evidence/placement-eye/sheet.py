"""Sheet builder: footage frames on top (yellow clip+second), draft game shots below (cyan).
sheet(name, foot=[(clip, sec[, flip])...], game=[(label, 'x,y,z', 'x,y,z', fov)...], cols=6)"""
import os, subprocess, sys
from PIL import Image, ImageDraw, ImageFont

S = os.path.dirname(os.path.abspath(__file__))
V = os.path.expanduser('~/risd-godot-ingestion/collection-expansion/verified')
D = os.path.expanduser(os.environ.get('DRAFT', '~/risd-godot-ingestion/collection-expansion/rebuild-placement-eye-copy/extension'))
TM = 'zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p'
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 15)


def frame(clip, sec, flip=False):
    out = f'{S}/f/c{clip}_{sec}.jpg'
    if not os.path.exists(out):
        vf = TM + (',hflip,vflip' if flip else '') + ',scale=540:-2'
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-ss', str(sec), '-i', f'{V}/IMG_{clip}.MOV', '-vf', vf, '-frames:v', '1', '-q:v', '3', out], check=True)
    return out


def shots(name, game, size='540x960'):
    args, outs = [], []
    for i, g in enumerate(game):
        out = f'{S}/g/{name}_{i}.png'
        outs.append(out)
        if g[1] == 'plan':
            args.append(f'plan:{out}:{g[2]}:{g[3]}:{g[4]}:{size}')
        else:
            args.append(f'{out}:{g[1]}:{g[2]}:{g[3]}:{g[4] if len(g) > 4 else size}')
    os.makedirs(f'{S}/g', exist_ok=True)
    r = subprocess.run(['timeout', '300', 'godot', '--path', D, '--display-driver', 'x11', '--rendering-method', 'gl_compatibility', '--script', f'{S}/eye_shot.gd', '--'] + args, capture_output=True, text=True)
    if 'EYE_SHOT done' not in r.stdout:
        sys.exit(r.stdout[-2000:] + r.stderr[-2000:])
    return outs


def tile(path, label, color, w, h):
    im = Image.open(path).convert('RGB')
    im.thumbnail((w, h))
    t = Image.new('RGB', (w, h), (20, 20, 20))
    t.paste(im, ((w - im.width) // 2, (h - im.height) // 2))
    d = ImageDraw.Draw(t)
    d.rectangle([0, 0, d.textlength(label, font=FONT) + 8, 20], fill=(0, 0, 0))
    d.text((4, 2), label, fill=color, font=FONT)
    return t


def sheet(name, foot, game, cols=6, out_dir=None):
    w = 1200 // cols
    h = w * 16 // 9
    tiles = [tile(frame(*f), f'{f[0]} {f[1]}s', (255, 230, 0), w, h) for f in foot]
    pad = (-len(tiles)) % cols
    tiles += [Image.new('RGB', (w, h), (20, 20, 20))] * pad
    tiles += [tile(p, 'game ' + g[0], (0, 255, 255), w, h) for p, g in zip(shots(name, game), game)]
    rows = -(-len(tiles) // cols)
    im = Image.new('RGB', (w * cols, h * rows), (20, 20, 20))
    for i, t in enumerate(tiles):
        im.paste(t, (i % cols * w, i // cols * h))
    if im.height > 1200:
        im = im.resize((im.width * 1200 // im.height, 1200))
    out = f'{out_dir or S}/{name}.jpg'
    for q in (82, 74, 66, 58, 50, 42):
        im.save(out, quality=q)
        if os.path.getsize(out) < 295000:
            break
    print(out, im.size, os.path.getsize(out), 'q', q)
