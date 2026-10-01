"""Select the two source-matched Muse panels; discard the invented middle strip.
Run: python3 image-work/collection-room-remodel/european-door-assemble.py
"""
from pathlib import Path
import hashlib,json
from PIL import Image
app=Path(__file__).resolve().parent
review=json.loads((app/'european-two-panel-door-review.json').read_text())
source=app/'trial/european-two-panel-door-original.webp'
assert hashlib.sha256(source.read_bytes()).hexdigest()==review['native_sha256']
image=Image.open(source);assert image.size==(1440,1760)
assert len(review['assembly_regions_px'])==2
for index,region in enumerate(review['assembly_regions_px']):
    target=app/'trial'/f'european-two-panel-door-{index}.png'
    image.crop(region).save(target)
    assert hashlib.sha256(target.read_bytes()).hexdigest()==review['assembly_sha256'][target.name]
assert review['assembly_regions_px'][0][3]<1100 and review['assembly_regions_px'][1][1]>1200
print('Two panel crops verified; invented middle strip excluded')
