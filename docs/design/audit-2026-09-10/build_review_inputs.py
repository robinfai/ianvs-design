"""Lay out unchanged audit screenshots for ImageGen's five-reference limit."""
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
manifest = json.loads((ROOT / 'manifest.json').read_text())
excluded = {s['name'] for s in manifest if s.get('verified') is False}
groups = {
    '01-connection-global': lambda n: int(n.split('-')[0].rstrip('b')) <= 12,
    '02-actions': lambda n: 13 <= int(n.split('-')[0].rstrip('b')) <= 17,
    '03-inputs-fields-menus': lambda n: 18 <= int(n.split('-')[0].rstrip('b')) <= 27 or n.startswith('45-'),
    '04-inputs-selection': lambda n: 28 <= int(n.split('-')[0].rstrip('b')) <= 33 or n.startswith(('38-', '43-', '44-')),
    '05-date-time': lambda n: 34 <= int(n.split('-')[0].rstrip('b')) <= 42 and not n.startswith('38-'),
    '06-navigation': lambda n: 46 <= int(n.split('-')[0].rstrip('b')) <= 58,
    '07-feedback': lambda n: 59 <= int(n.split('-')[0].rstrip('b')) <= 72,
    '08-supplements': lambda n: 73 <= int(n.split('-')[0].rstrip('b')) <= 84,
    '09-workspace': lambda n: 85 <= int(n.split('-')[0].rstrip('b')) <= 88 or n.startswith(('107-', '108-')),
    '10-overlays': lambda n: 89 <= int(n.split('-')[0].rstrip('b')) <= 100 or n.startswith(('119-', '120-', '121-', '130-', '131-')),
    '11-foundations-search': lambda n: 101 <= int(n.split('-')[0].rstrip('b')) <= 106 or n.startswith('122-'),
    '12-responsive': lambda n: 109 <= int(n.split('-')[0].rstrip('b')) <= 118 or 124 <= int(n.split('-')[0].rstrip('b')) <= 129,
}
out = ROOT / 'review-inputs'
out.mkdir(exist_ok=True)
font = ImageFont.truetype('/System/Library/Fonts/Menlo.ttc', 23)
all_groups = []
for group, accepts in groups.items():
    items = [s for s in manifest if s['name'] not in excluded and accepts(s['name'])]
    sheets = []
    for start in range(0, len(items), 4):
        batch = items[start:start + 4]
        # No screenshots are cropped, stretched, retouched, or recolored.
        sheet = Image.new('RGB', (2928, math.ceil(len(batch) / 2) * 1064 + 16), '#e9edf2')
        draw = ImageDraw.Draw(sheet)
        for i, item in enumerate(batch):
            x, y = 16 + (i % 2) * 1456, 16 + (i // 2) * 1064
            draw.text((x + 8, y + 6), item['name'], font=font, fill='#111827')
            original = Image.open(ROOT / 'screenshots' / (item['name'] + '.png')).convert('RGB')
            sheet.paste(original, (x, y + 40))
        path = out / f'{group}-{start // 4 + 1}.png'
        sheet.save(path)
        sheets.append(str(path))
    all_groups.append({'id': group, 'screenshots': items, 'references': sheets})
(ROOT / 'review-groups.json').write_text(json.dumps(all_groups, ensure_ascii=False, indent=2))
print(json.dumps([{ 'id': g['id'], 'screenshots': len(g['screenshots']), 'sheets': len(g['references']) } for g in all_groups], ensure_ascii=False))
