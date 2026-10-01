from pathlib import Path
from scrapling.fetchers import Fetcher
import urllib.request,re,hashlib,json
out=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-identities-api-v1');url='https://risdmuseum.org/art-design/collection/head-woman-70058';r=Fetcher.get(url);assert r.status==200;(out/'villon-head.html').write_text(r.html_content);images=re.findall(r'data-zoom-url="([^"]+)"',r.html_content)
if images:
 p=out/'villon-head-zoom.jpg';p.write_bytes(urllib.request.urlopen(images[0],timeout=30).read());(out/'villon-head-image.json').write_text(json.dumps({'url':images[0],'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()},indent=2)+'\n')
print(len(images),'images')
