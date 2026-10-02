from pathlib import Path
from scrapling.fetchers import Fetcher
import urllib.parse,json
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v3');out.mkdir(exist_ok=False)
review=[]
for q in ['Severini','Lipchitz','Archipenko','Laurens','Lhote','Leger','Rivera','Zadkine','Duchamp-Villon']:
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':q,'items_per_page':'25'});r=Fetcher.get(url);assert r.status==200;j=r.json();assert isinstance(j,list);(out/(q.lower()+'.json')).write_text(json.dumps(j,indent=2)+'\n')
 candidates=[{k:x.get(k) for k in ['id','primaryMaker','title','objectNumber','medium','dimensions','url']} for x in j if any(s in str(x.get('medium','')).lower() for s in ['canvas','bronze','brass','stone'])]
 review.append({'query':q,'url':url,'rows':len(j),'candidates':candidates});print(q,json.dumps(candidates),flush=True)
(out/'query-review.json').write_text(json.dumps(review,indent=2)+'\n')
