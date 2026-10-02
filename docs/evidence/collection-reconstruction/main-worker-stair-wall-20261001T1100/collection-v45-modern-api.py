from pathlib import Path
from scrapling.fetchers import Fetcher
import urllib.parse,json
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-identities-api-v1');out.mkdir(exist_ok=False);review=[]
for q in ['Lipchitz','Villon','Delaunay','Fresnaye','Lhote','Gromaire']:
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':q,'items_per_page':'25'});r=Fetcher.get(url);assert r.status==200;rows=r.json();assert isinstance(rows,list);(out/(q.lower()+'.json')).write_text(json.dumps(rows,indent=2)+'\n');c=[{k:x.get(k) for k in ['id','objectNumber','title','medium','dimensions','url']} for x in rows];review.append({'query':q,'url':url,'results':c});print(q,json.dumps(c),flush=True)
(out/'query-review.json').write_text(json.dumps(review,indent=2)+'\n')
