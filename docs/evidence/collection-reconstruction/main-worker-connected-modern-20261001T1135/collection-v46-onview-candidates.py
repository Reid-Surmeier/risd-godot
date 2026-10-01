from pathlib import Path
from scrapling.fetchers import Fetcher
import re,json,urllib.parse
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v3')
r=Fetcher.get('https://risdmuseum.org/art-design/collection');assert r.status==200;(out/'collection-query-form.html').write_text(r.html_content)
summary=[]
for page in range(3):
 url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'field_on_view':'1','search_api_fulltext':'Oil on canvas','items_per_page':'100','page':str(page)});r=Fetcher.get(url);assert r.status==200;j=r.json();assert isinstance(j,list);(out/f'onview-paintings-{page}.json').write_text(json.dumps(j,indent=2)+'\n');summary.append({'url':url,'rows':len(j),'all_onview':all(x['onView'] for x in j),'types':sorted(set(t for x in j for t in x['type']))})
 for x in j:
  if x['onView'] and 'Painting' in x['type']:print(x['primaryMaker'],x['title'],x['objectNumber'],x['dimensions'],flush=True)
(out/'onview-query-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
