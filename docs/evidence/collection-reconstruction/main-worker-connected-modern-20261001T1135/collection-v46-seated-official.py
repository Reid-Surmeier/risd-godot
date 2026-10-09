from pathlib import Path
from scrapling.fetchers import Fetcher
import re,urllib.request,json,hashlib
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v3');url='https://risdmuseum.org/art-design/collection/seated-woman-67089';r=Fetcher.get(url);assert r.status==200;(out/'seated-woman.html').write_text(r.html_content);imgs=re.findall(r'data-zoom-url="([^"]+)"',r.html_content);assert imgs
rows=[]
for i,u in enumerate(imgs):
 p=out/f'seated-woman-zoom-{i}.jpg';p.write_bytes(urllib.request.urlopen(u,timeout=30).read());rows.append({'url':u,'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(out/'seated-woman-image-source.json').write_text(json.dumps(rows,indent=2)+'\n');print('Official photographs',len(rows))
