from pathlib import Path
from scrapling.fetchers import Fetcher
import json,urllib.parse,urllib.request,re,hashlib
p=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v2');summary=[]
for q in ['pumpkin','Matisse','Gritchenko','Bourgeois','Survage','Cezanne','Zadkine','78.160']:
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':q,'items_per_page':'25'});r=Fetcher.get(url);assert r.status==200;j=r.json();assert isinstance(j,list);(p/(q.lower()+'.json')).write_text(json.dumps(j,indent=2)+'\n');c=[{k:x.get(k) for k in ['id','primaryMaker','title','objectNumber','medium','dimensions','url']} for x in j if q in ['pumpkin','78.160'] or 'canvas' in str(x.get('medium','')).lower() or 'bronze' in str(x.get('medium','')).lower()];summary.append({'query':q,'url':url,'results':c});print(q,json.dumps(c),flush=True)
(p/'additional-query-review.json').write_text(json.dumps(summary,indent=2)+'\n')
