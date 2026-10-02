from pathlib import Path
from scrapling.fetchers import Fetcher
import urllib.parse,json
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v6');out.mkdir(exist_ok=False);summary=[]
for q in ['Battle','Tourney','Combat','Massacre','Soldiers','Fresnaye']:
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':q,'items_per_page':'25'});r=Fetcher.get(url);assert r.status==200;j=r.json();assert isinstance(j,list);(out/(q.replace(' ','-').lower()+'.json')).write_text(json.dumps(j,indent=2)+'\n');c=[{k:x.get(k) for k in ['id','primaryMaker','title','objectNumber','medium','dimensions','url']} for x in j if 'canvas' in str(x.get('medium','')).lower()];summary.append({'query':q,'url':url,'rows':len(j),'candidates':c});print(q,json.dumps(c),flush=True)
(out/'query-review.json').write_text(json.dumps(summary,indent=2)+'\n')
