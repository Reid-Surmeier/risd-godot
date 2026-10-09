from pathlib import Path
from scrapling.fetchers import Fetcher
import urllib.parse,urllib.request,json,re,hashlib
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v2');out.mkdir(exist_ok=False);summary=[]
for q in ['Dufresne','Gleizes','Metzinger','Picabia','Weber','Feast','Supper','Orloff']:
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':q,'items_per_page':'25'});r=Fetcher.get(url);assert r.status==200;j=r.json();assert isinstance(j,list);(out/(q.lower()+'.json')).write_text(json.dumps(j,indent=2)+'\n');c=[{k:x.get(k) for k in ['id','primaryMaker','title','objectNumber','medium','dimensions','url']} for x in j if 'canvas' in str(x.get('medium','')).lower() or 'bronze' in str(x.get('medium','')).lower()];summary.append({'query':q,'url':url,'rows':len(j),'candidates':c});print(q,json.dumps(c),flush=True)
for name,url in [('girl-chair','https://risdmuseum.org/art-design/collection/girl-chair-78160')]:
 r=Fetcher.get(url);assert r.status==200;(out/(name+'.html')).write_text(r.html_content);ims=re.findall(r'data-zoom-url="([^"]+)"',r.html_content)
 for i,u in enumerate(ims[:3]):
  p=out/(name+f'-{i}.jpg');p.write_bytes(urllib.request.urlopen(u,timeout=30).read());summary.append({'file':str(p),'url':u,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(out/'query-review.json').write_text(json.dumps(summary,indent=2)+'\n')
