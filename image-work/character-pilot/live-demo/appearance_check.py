"""Fail on material color loss, stepped blink timing, atlas bleed or unrelated repaint.
Run appearance_check.gd in the native project, then this file with that project path.
"""
from pathlib import Path
import sys,json
import numpy as np
from PIL import Image
project=Path(sys.argv[1])
def frame(name):return np.asarray(Image.open(project/('appearance-'+name+'.png')).convert('RGB')).astype(float)
current,reference=frame('current-game'),frame('reference-game')
color=float(np.abs(current-reference)[275:435,405:555].mean())
levels=json.loads((project/'appearance-check.json').read_text())['blink_levels']
jump=max(abs(a-b) for a,b in zip(levels,levels[1:]))
opened,closed=frame('closure-00'),frame('closure-16')
change=np.abs(opened-closed).max(axis=2)>2
outside=change.copy();outside[340:470,340:620]=False
bleed=0
for x in [360,515]:
 eye=closed[355:450,x:x+90]
 bleed+=int(((eye[:,:,2]>eye[:,:,0]+8)&(eye[:,:,2]>eye[:,:,1]+4)).sum())
visibility=[]
for index in [8,12,16,20,24,28,36]:
 visible,hidden=frame('dust-visible-%02d'%index),frame('dust-hidden-%02d'%index)
 visibility.append(int((np.abs(visible-hidden)[280:470,375:585].max(axis=2)>8).sum()))
receipt={'mean_material_color_error_255':color,'maximum_blink_level_jump':jump,'distinct_blink_levels':len(set(round(x,3) for x in levels)),'outside_face_changed_pixels':int(outside.sum()),'closed_eye_blue_bleed_pixels':bleed,'native_render_compared_to_original_material':True,'dust_visible_pixels':visibility}
(project/'appearance-metrics.json').write_text(json.dumps(receipt,indent=2)+'\n')
assert max(visibility)>50 and sum(n>50 for n in visibility)>=3,('Dust hidden by avatar',visibility)
assert color<1,receipt
assert jump<.35 and receipt['distinct_blink_levels']>=6 and levels[-1]==0,receipt
assert outside.sum()==0 and bleed==0,receipt
print('PASS actual-render color equivalence, smooth blink levels, eyelid skin and unaffected pixels:',receipt)
