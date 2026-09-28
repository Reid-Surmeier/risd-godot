"""Assemble unretouched orbit sheets and pin every captured image's bytes."""
import hashlib
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).parent
for variant, letter in [('seam-trial', 'A'), ('source', 'B')]:
    folder = root / f'relief-{variant}-captures'
    assert len(list(folder.glob('*.png'))) == 16
    sheet = Image.new('RGB', (1536, 1224), 'white')
    draw = ImageDraw.Draw(sheet)
    for index, angle in enumerate(range(0, 360, 30)):
        image = Image.open(folder / f'20260811122415-{angle:03}.png').convert('RGB')
        assert image.size == (768, 768)
        image.thumbnail((384, 384))
        x, y = index % 4 * 384, index // 4 * 408
        sheet.paste(image, (x, y + 24))
        draw.text((x + 8, y + 5), f'{letter} / {angle} degrees', fill='black')
    sheet.save(root / f'relief-orbit-{letter}.jpg', quality=92)
files = sorted(root.glob('relief-*-captures/*.png')) + sorted(root.glob('relief-orbit-*.jpg'))
(root / 'relief-capture-sha256.txt').write_text(''.join(
    f'{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.relative_to(root)}\n' for path in files))
print(f'Pinned {len(files)} evidence images')
