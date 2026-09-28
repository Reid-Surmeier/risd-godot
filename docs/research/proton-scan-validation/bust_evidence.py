"""Create unretouched, neutral-label bust orbit sheets for image-only review."""
import hashlib
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).parent
for variant, letter in [('original', 'A'), ('source', 'B')]:
    folder = root / f'bust-{variant}-captures'
    assert len(list(folder.glob('*.png'))) == 32
    for scan_id in ('20260811123051', '20260820133334'):
        sheet = Image.new('RGB', (1536, 1224), 'white')
        draw = ImageDraw.Draw(sheet)
        for index, angle in enumerate(range(0, 360, 30)):
            image = Image.open(folder / f'{scan_id}-{angle:03}.png').convert('RGB')
            assert image.size == (768, 768)
            image.thumbnail((384, 384))
            x, y = index % 4 * 384, index // 4 * 408
            sheet.paste(image, (x, y + 24))
            draw.text((x + 8, y + 5), f'{letter} / {angle} degrees', fill='black')
        sheet.save(root / f'bust-{scan_id}-{letter}.jpg', quality=92)
files = sorted(root.glob('bust-*-captures/*.png')) + sorted(root.glob('bust-202*.jpg'))
(root / 'bust-capture-sha256.txt').write_text(''.join(
    f'{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.relative_to(root)}\n' for path in files))
print(f'Pinned {len(files)} evidence images')
