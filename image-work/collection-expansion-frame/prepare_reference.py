"""Rectify the complete observed frame; blank only the authentic canvas for Muse."""
import hashlib
import json
import pathlib
import shutil
import numpy as np
from PIL import Image, ImageDraw

app=pathlib.Path(__file__).resolve().parent
root=pathlib.Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
source=root/'anchors/frame-6386-122.png'
view=next(v for x in json.loads((root/'scale-fit-v1/result.json').read_text()) if x['component']=='3'
          for v in x['views'] if v['image']=='IMG_6386/000122.jpg')
pixels=np.array(view['pixel_corners'])*1.5
# Match catalogue canvas aspect, retaining a margin around the whole carved frame.
dest=np.array([[300,300],[1300,300],[1300,1131],[300,1131]],float)
a=[];b=[]
for (x,y),(u,v) in zip(dest,pixels):
    a.extend([[x,y,1,0,0,0,-u*x,-u*y],[0,0,0,x,y,1,-v*x,-v*y]]);b.extend([u,v])
h=np.linalg.solve(a,b)
assert np.max(np.abs(np.array(a)@h-b))<1e-7
ref=Image.open(source).convert('RGB').transform((1600,1431),Image.Transform.PERSPECTIVE,h,Image.Resampling.BICUBIC)
ref.save(app/'references/rectified-source.png')
ImageDraw.Draw(ref).rectangle((300,300,1300,1131),fill='white')
ref.save(app/'references/frame-photo.png')
shutil.copyfile(app.parent/'grand-gallery-v4/frames2/prompts/frame.txt',app/'prompts/frame.txt')
hashfile=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
plan={'attempts':[{'id':'arabs-frame-002','prompt':'prompts/frame.txt','promptSha256':hashfile(app/'prompts/frame.txt'),
    'size':'1760x1568','inputs':[{'path':'references/frame-photo.png','sha256':hashfile(app/'references/frame-photo.png')}]}]}
(app/'generation-preflight.json').write_text(json.dumps(plan,indent=2))
(app/'recipe-full-frame.json').write_text(json.dumps({'procedure':'edit','plan':'generation-preflight.json','attempt':'arabs-frame-002'},indent=2))
(app/'source.json').write_text(json.dumps(dict(video='IMG_6386.MOV',sample_2fps=122,nominal_seconds=60.5,
    source_sha256=hashfile(source),corners_native=pixels.tolist(),rectification_output_to_source=h.tolist(),
    canvas_dimensions_m=[.651,.541],painting_accession='35.786',
    prompt_reused='image-work/grand-gallery-v4/frames2/prompts/frame.txt',
    source_note='Canvas-plane rectification does not remove perspective from protruding carving.',
    quoted_price_usd=.01,price_source='https://openrouter.ai/meta/muse-image',price_checked='2026-09-29'),indent=2))
