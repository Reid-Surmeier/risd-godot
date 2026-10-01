from pathlib import Path
from scrapling.fetchers import Fetcher
import json,urllib.request,re,hashlib,urllib.parse
p=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v2');manifest=[]
for name,url in [('matisse-pumpkin','https://risdmuseum.org/art-design/collection/green-pumpkin-57037')]:
 r=Fetcher.get(url);assert r.status==200;(p/(name+'.html')).write_text(r.html_content);ims=re.findall(r'data-zoom-url="([^"]+)"',r.html_content);assert ims
 f=p/(name+'-zoom.jpg');f.write_bytes(urllib.request.urlopen(ims[0],timeout=30).read());manifest.append({'url':ims[0],'file':str(f),'sha256':hashlib.sha256(f.read_bytes()).hexdigest()})
for q in ['Archipenko','Laurens','Lehmbruck','festival','Friesz','Lurcat','Beckmann','Cezanne river']:
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':q,'items_per_page':'25'});r=Fetcher.get(url);assert r.status==200;j=r.json();assert isinstance(j,list);(p/(q.lower().replace(' ','-')+'.json')).write_text(json.dumps(j,indent=2)+'\n');c=[{k:x.get(k) for k in ['id','primaryMaker','title','objectNumber','medium','dimensions','url']} for x in j if 'canvas' in str(x.get('medium','')).lower() or 'bronze' in str(x.get('medium','')).lower()];print(q,json.dumps(c),flush=True)
(p/'official-image-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
