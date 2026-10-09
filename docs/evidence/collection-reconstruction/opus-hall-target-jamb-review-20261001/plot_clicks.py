"""Plan drawing of floor clicks at the Hall door. plot_clicks.py <label=json>... <out.png>; each json may be given twice-merged with +"""
import json, sys
from PIL import Image, ImageDraw
L=26.3; SC=150; X0,Z0,W,Hh=-3.4,-29.6,6.8,7.0
names=['grey-to-hall-on-axis','hall-to-grey-on-axis','grey-to-hall-shallow-diagonal-valid-start','grey-to-hall-line-misses-door','hall-to-grey-line-misses-door','hall-to-grey-long-past-one-bench-deep-target','grey-to-hall-deep-target-past-bench']
cols=[(214,39,40),(31,119,180),(44,160,44),(148,103,189),(255,127,14),(140,86,75),(23,150,170)]
pw,ph=int(W*SC),int(Hh*SC)
panels=sys.argv[1:-1]
sheet=Image.new('RGB',((pw+30)*len(panels),ph+44+18*len(names)),'white')
def P(x,z): return (int((x-X0)*SC),int((z-Z0)*SC))
for k,item in enumerate(panels):
    tag,paths=item.split('='); clicks={}
    for p in paths.split('+'):
        for c in json.load(open(p))['clicks']: clicks[c['name']]=c
    im=Image.new('RGB',(pw,ph),(250,248,242)); d=ImageDraw.Draw(im)
    for x0,x1 in [(-3.4,-0.95),(0.95,3.4)]: d.rectangle([P(x0,-27.06),P(x1,-L)],fill=(205,205,205))
    for x0 in (-0.95,0.905): d.rectangle([P(x0,-27.25),P(x0+0.045,-L)],fill=(70,70,70))
    d.line([P(-3.4,-L),P(3.4,-L)],fill=(40,60,140))
    d.text(P(-3.35,-29.5),'grey gallery',fill=(0,0,0)); d.text(P(-3.35,-26.75),'wall thickness',fill=(60,60,60)); d.text(P(-3.35,-L+0.05),'Hall wall line',fill=(40,60,140)); d.text(P(-3.35,-22.75),'Hall (continues south)',fill=(0,0,0))
    for i,n in enumerate(names):
        c=clicks[n]; pts=[P(*c['start'])]+[P(*p) for p in c['path']]
        d.line(pts,fill=cols[i],width=2)
        for cl in c['clicks']:
            x,z=P(*cl['clicked']); d.line([(x-6,z-6),(x+6,z+6)],fill=cols[i],width=2); d.line([(x-6,z+6),(x+6,z-6)],fill=cols[i],width=2)
        e=pts[-1]; d.ellipse([e[0]-5,e[1]-5,e[0]+5,e[1]+5],outline=cols[i],width=2)
    sheet.paste(im,(k*(pw+30),22)); ds=ImageDraw.Draw(sheet)
    ds.text((k*(pw+30)+4,4),f'{tag}: one floor click each, from above, north at the top. Cross = clicked point (some lie outside the drawing); ring = where the visitor stopped.',fill=(0,0,0))
    for i,n in enumerate(names):
        c=clicks[n]; ds.text((k*(pw+30)+4,ph+28+18*i),f"{n}: {'arrives' if c['reached'] else 'does not arrive'}, stops at ({c['clicks'][-1]['stopped'][0]:.2f}, {c['clicks'][-1]['stopped'][1]:.2f}), largest step {c['largest_step_m']:.3f} m",fill=cols[i])
sheet.save(sys.argv[-1]); print(sheet.size)
