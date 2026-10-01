from pathlib import Path
import json,html
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v40-loop');j=json.loads((out/'geometry.json').read_text());scale=17
xy=lambda x,z:((x+8)*scale+15,(z+9)*scale+55)
body=[]
colours={'Rockefeller':'#bbaa8d','adjacent gallery':'#e6dcca','light Renaissance room':'#d1cfca','dark medieval room':'#666975','Grand Gallery':'#728caa','grey French gallery':'#b7b6af','purple elevator-5 connector':'#9f80b4'}
names={'Rockefeller':'Rockefeller','adjacent gallery':'European gallery','light Renaissance room':'Renaissance','dark medieval room':'Medieval','Grand Gallery':'Grand Gallery','grey French gallery':'French gallery','purple elevator-5 connector':'Elevator5'}
for r in j['rooms']:
 a,b,c,d=r['bounds'];x,y=xy(a,c);w,h=(b-a)*scale,(d-c)*scale;colour=colours.get(r['label'],'#ede4d5');body.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{colour}" stroke="#444" stroke-width="2"/>')
 if r['label'] in names:
  nx,ny=xy((a+b)/2,(c+d)/2);body.append(f'<text x="{nx}" y="{ny}" text-anchor="middle" font-size="12" fill="{"white" if r["label"]=="dark medieval room" else "#24272a"}">{html.escape(names[r["label"]])}</text>')
 for side,op in r['openings'].items():
  fixed=a if side=='west' else b if side=='east' else c if side=='north' else d
  p,q=(xy(fixed,op[0]),xy(fixed,op[1])) if side in ['west','east'] else (xy(op[0],fixed),xy(op[1],fixed))
  body.append(f'<path d="M{p[0]} {p[1]}L{q[0]} {q[1]}" stroke="#fff" stroke-width="5"/>')
points=' '.join(f'{x:g},{z:g}' for x,z in [xy(*p) for p in j['continuous_loop_waypoints']]);body.append(f'<polyline points="{points}" fill="none" stroke="#bf3948" stroke-width="2" stroke-dasharray="5 3"/>')
p=Path('docs/evidence/collection-reconstruction/main-worker-connected-loop-20261001T0735/route-plan.svg');p.write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 805"><rect width="390" height="805" fill="#f3eee3"/><text x="15" y="20" font-family="sans-serif" font-size="15">Authored connected room study</text><text x="15" y="40" font-family="sans-serif" font-size="11">Red circuit: continuous collision check; dimensions provisional</text><g font-family="sans-serif">'+''.join(body)+'</g></svg>');assert len(j['continuous_loop_waypoints'])==34;print('Authored plan and closed33-segment route written')
