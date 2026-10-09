from pathlib import Path
from scrapling.fetchers import Fetcher
import json,urllib.request,re,hashlib
p=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/modern-candidates-v2');url='https://risdmuseum.org/art-design/collection/banks-river-au-bord-dune-riviere-43255';r=Fetcher.get(url);assert r.status==200;(p/'cezanne-river.html').write_text(r.html_content);ims=re.findall(r'data-zoom-url="([^"]+)"',r.html_content);assert ims
f=p/'cezanne-river-zoom.jpg';f.write_bytes(urllib.request.urlopen(ims[0],timeout=30).read());(p/'cezanne-river-image.json').write_text(json.dumps({'url':ims[0],'file':str(f),'sha256':hashlib.sha256(f.read_bytes()).hexdigest()},indent=2)+'\n')
