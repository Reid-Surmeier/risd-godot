from pathlib import Path
import json,urllib.parse
from scrapling.fetchers import Fetcher
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/medieval-fragments-api-v1');out.mkdir(exist_ok=False);review=[]
for term in ['jamb','apostle','stone figure','saint peter','saint paul','relief']:
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':term,'items_per_page':'25'});r=Fetcher.get(url);assert r.status==200;d=r.json();assert isinstance(d,list);(out/(term.replace(' ','-')+'.json')).write_text(json.dumps(d,indent=2)+'\n');rows=[{k:x.get(k) for k in ['id','objectNumber','title','medium','dimensions','url']} for x in d];review.append({'query':term,'url':url,'count':len(d),'results':rows});print(term,json.dumps(rows),flush=True)
(out/'query-review.json').write_text(json.dumps(review,indent=2)+'\n')
