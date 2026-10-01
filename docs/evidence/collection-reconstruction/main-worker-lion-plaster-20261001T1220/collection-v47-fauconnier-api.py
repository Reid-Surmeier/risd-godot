from pathlib import Path
from scrapling.fetchers import Fetcher
import urllib.parse,urllib.request,json,re,hashlib
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v7');out.mkdir(exist_ok=False)
url='https://risdmuseum.org/api/v1/collection?'+urllib.parse.urlencode({'search_api_fulltext':'Mountaineers Attacked','items_per_page':'25'})
r=Fetcher.get(url);assert r.status==200;j=r.json();(out/'api.json').write_text(json.dumps(j,indent=2)+'\n')
rows=[x for x in j if 'Mountaineers' in x.get('title','')];assert len(rows)==1;row=rows[0];print(json.dumps(row),flush=True)
r=Fetcher.get(row['url']);assert r.status==200;(out/'official.html').write_text(r.html_content)
urls=re.findall(r'data-zoom-url="([^"]+)"',r.html_content);assert urls
data=urllib.request.urlopen(urls[0],timeout=30).read();(out/'official-zoom.jpg').write_bytes(data)
(out/'official-image-manifest.json').write_text(json.dumps({'api_url':url,'object':row,'image_url':urls[0],'sha256':hashlib.sha256(data).hexdigest(),'visual_match_verified':False},indent=2)+'\n')
