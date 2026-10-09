"""Assemble ledger.json from the hand-recorded observations below plus catalogue fields and hashes read from api/, photos/ and frames/."""
import glob, hashlib, html, json
from pathlib import Path
here = Path(__file__).parent
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
records = {}
for f in sorted(glob.glob(str(here / 'api' / '*.json'))):
    if not f.endswith('manifest.json'):
        for x in json.loads(Path(f).read_text()): records.setdefault(x['objectNumber'], (x, 'api/' + Path(f).name))
photos = {e['accession']: e for e in json.loads((here / 'photos/manifest.json').read_text())}
fm = json.loads((here / 'frames/manifest.json').read_text())
frames = {f"{f['seconds']:.2f}": f for f in fm['frames']}
def obj(slot, group, wall, status, basis, seen, where, evidence, limits, acc=None, sheet=None, label=None, root_id=None, root_called=None, built=False):
    o = {'slot': slot, 'group': group, 'wall': wall, 'status': status, 'basis': basis, 'built_in_root': built, 'root_inventory_id': root_id, 'root_inventory_called': root_called,
         'video': 'IMG_6383.MOV', 'seen_seconds': seen, 'source_frames': [{'seconds': float(s), 'png_sha256': frames[s]['png_sha256'], 'kept_file': 'frames/' + frames[s]['kept_file']} for s in seen],
         'observed_position': where, 'visual_evidence': evidence, 'label_read': label, 'limits': limits, 'placement_accepted': False, 'unlisted_dimensions_accepted': False}
    if acc:
        r, src = records[acc]
        o.update({'accession': acc, 'catalogue_id': r['id'], 'title': html.unescape(r['title']), 'maker': r['primaryMaker'], 'dating': f"{r['datingYearFrom']}-{r['datingYearTo']}",
                  'medium': '; '.join(m.replace('\n', ' ') for m in r['medium']), 'dimensions': r['dimensions'], 'on_view_flag': r['onView'], 'public_domain_flag': r['publicDomain'], 'link': r['url'],
                  'api_json': src, 'api_json_sha256': sha(here / src), 'carousel_photos_on_page': photos[acc]['carousel_photos'],
                  'photos': [{k: p[k] for k in ('file', 'url', 'asset_copyright', 'sha256')} for p in photos[acc]['photos']], 'comparison_sheet': f'sheets/{sheet}.jpg'})
    elif sheet:
        o['comparison_sheet'] = f'sheets/{sheet}.jpg'
    return o
C, P, U, B = 'confirmed', 'probable', 'unmatched', 'already-built'
objects = [
 obj('R01', 'south wall', 'south', C, 'photo', ['6.10', '68.50'], 'South wall, east half, in a white box mount above a low white platform with a label stand.',
     'Tall dark red velvet with gold fringe top and bottom, two narrow horizontal bands, and rows of gold stag heads with antlers and curled horns. Every motif position matches the official photograph.',
     'Catalogue gives only the 127 cm length; width is not listed.', '23.307X', 'R01-velvet-cover-23.307X', root_id='burgundy-textile', root_called='Burgundy repeated floral textile in white mount'),
 obj('R02', 'south wall', 'south', C, 'photo', ['11.50', '60.60', '68.50'], 'South wall, west half, hung directly on the wall above the same low platform.',
     'Tapestry of two men, one in a gold jerkin and one in a red cap and blue coat carrying a tool, over fruiting bushes on a dark blue ground with a dark border. Matches the official photograph figure for figure.',
     'None beyond resolution.', '29.280', 'R02-tapestry-29.280', root_id='hunting-tapestry', root_called='Green hunting tapestry: riders and foliage'),
 obj('R03', 'west wall', 'west', C, 'photo', ['15.10', '60.60'], 'West wall, south end, framed, with a wall label to its right.',
     'Virgin nursing the Child at left, an angel with a dish of fruit, a saint reading, a saint in green with a sword, tower and landscape behind. Matches the official photograph.',
     'The dark moulded frame is not in the catalogue photograph; frame size is unlisted.', '58.196', 'R03-painting-58.196', root_id='holy-family', root_called='Holy Family with female attendants, outdoor setting'),
 obj('R04', 'west wall', 'west', C, 'photo', ['18.30', '20.60', '21.30', '62.00'], 'In front of the shuttered west window on a white floor plinth under a tall acrylic hood.',
     'Standing pilgrim in a broad hat and short cape, tunic lifted from one thigh, a small dog at his feet on a rocky base. Matches the four official views, including the back.',
     'It is polychromed wood, not bronze. Catalogue gives only the 105.4 cm height. Plinth and hood sizes are unmeasured.', '21.398', 'R04-saint-roch-21.398', root_id='bronze-knight', root_called='Bronze young knight with hat/cape, rock base, large glass case'),
 obj('R05', 'west wall', 'west', C, 'photo and label', ['24.60', '62.00'], 'West wall, north end, in a wall-hung case: white shelf with a sloped label front and an acrylic hood.',
     'Veiled Virgin seated with the dead Christ slumped at her side, his head fallen back, on a leafy mound. Matches the official photograph.',
     'It is linden wood, not bronze. The case label and the 2020 caption date it ca. 1515-1525; the live catalogue record gives 1480-1510.', '59.128', 'R05-pieta-59.128', label='Tilman Riemenschneider / Pieta, ca. 1515-1525 / Linden wood',
     root_id='bronze-pieta', root_called='Virgin seated, dead Christ at her side, small wall glass case'),
 obj('R06', 'north wall', 'north', C, 'photo and label', ['30.00', '30.20', '63.90', '71.90'], 'North wall, west of the doorway to the long gallery, in a wall-hung case, wings open at an angle.',
     'Gabled gold-ground triptych: enthroned Madonna in dark blue with saints at the centre, Saint Michael over the dragon and two saints on the left wing, Crucifixion on the right wing. Matches the official photographs.',
     'Catalogue size 67 x 72.5 cm is for the triptych open flat; the wing angle in the case is unmeasured.', '2021.131', 'R06-triptych-2021.131', label='... Enthroned, with ... Angels, ca. 1320 / ... on wood panel',
     root_id='triptych', root_called='Open gold triptych in wall glass case'),
 obj('R07', 'north wall', 'north', B, 'root', ['63.90', '64.90'], 'North wall, east of the doorway.',
     'Pietro Perugino, Madonna and Child, 16.236. Already matched and installed by the root; listed here only to keep the wall order complete.', 'Not re-examined.', built=True, root_id='madonna-architecture', root_called='Pietro Perugino, Madonna and Child'),
 obj('R08', 'case A', 'east', C, 'photo', ['41.20', '49.80'], 'Case A (east wall, north of the tracery doorway), back panel, left.',
     'Small portrait of a dark-haired man in three-quarter view with hands joined in prayer, green ground, grey moulded frame. Matches the official photograph.',
     'The frame is not in the catalogue photograph. No legible label was found for it.', '45.042', 'R08-portrait-man-45.042', root_id='books-portraits-case', root_called='portrait (one of two)'),
 obj('R09', 'case A', 'east', C, 'photo', ['41.20', '46.40'], 'Case A, back panel, right.',
     'Arch-topped portrait of a woman in a white headdress and black dress, hands folded, in a brown arched frame. Matches the official photograph.',
     'The painted coat of arms on the back (official photograph 1) is not visible in the case.', '34.861', 'R09-portrait-woman-34.861', root_id='books-portraits-case', root_called='portrait (one of two)'),
 obj('R10', 'case A', 'east', C, 'photo and label', ['41.10', '41.20', '49.80'], 'Case A, deck, left, lying open on a sloped white mount.',
     'Two ivory leaves side by side, each with two tiers of scenes under three Gothic arches. Matches the official photograph of one leaf.',
     'Individual scenes are not resolved in the source.', '22.201', 'R10-diptych-22.201', label='Diptych with Scenes of the Nativity, the Crucifixion, and the Last Judgment, ca. 1275-1325',
     root_id='books-portraits-case', root_called='ivory narrative plaque'),
 obj('R11', 'case A', 'east', C, 'photo and label', ['41.10', '41.20', '49.80'], 'Case A, deck, centre left, standing on its fore-edge with its chains raised to a ring.',
     'Silver book-shaped cover with a banded spine and three chains gathered to a ring. Matches the official photographs.',
     'Filigree and niello are not resolved in the source.', '34.016', 'R11-book-cover-34.016', label='Book Cover, 1500-1550', root_id='books-portraits-case', root_called='bronze bucket'),
 obj('R12', 'case A', 'east', U, 'label only', ['41.20', '45.70', '46.40'], 'Case A, deck, centre right, open on a clear cradle.',
     'Small printed book open to a left page of verse and a right page with an engraving of an oval emblem above text.',
     'Identified by its case label only. Three catalogue searches (Montenay, Emblematum, Woeiriot) returned no record, so there is no accession, size or official photograph. The label year is not legible.',
     sheet='R12-emblem-book-label-only', label='... de Montenay, author / ... Woeiriot, engraver / One Hundred Christian Emblems (Emblematum Christianorum Centuria)',
     root_id='books-portraits-case', root_called='open printed book'),
 obj('R13', 'case A', 'east', C, 'photo and label', ['41.20', '45.70', '46.40'], 'Case A, deck, right.',
     'Waisted tin-glazed jar with a monk saint in a yellow cartouche, blue ground with orange, green and white flowers. Matches the official photograph.',
     'The reverse (official photograph 1) is not filmed.', '35.713', 'R13-albarello-35.713', label='Italian / Drug Jar (Albarello), ca. 1550 / Earthenware with tin glaze and enamels',
     root_id='books-portraits-case', root_called='blue/gold drug jar'),
 obj('R14', 'case B', 'east', C, 'photo and label', ['55.60', '56.00'], 'Case B (east wall, south of the tracery doorway), back panel, left.',
     'Dish with a large bust of a woman in profile to the right, yellow dress, two lettered scrolls on a dark blue ground. Matches the official photograph.',
     'Which of the two "Bella Donna Plate" labels belongs to which plate is not established.', '46.391', 'R14-R15-bella-donna-plates', label='Bella Donna Plate (two labels)',
     root_id='majolica-medals-case', root_called='plate (one of two)'),
 obj('R15', 'case B', 'east', C, 'photo and label', ['56.00'], 'Case B, back panel, right.',
     'Lustred dish with a small profile bust in the well and a rim of large radiating drops. Matches the official photograph.',
     'Colours are washed out by reflection in the source.', '57.302', 'R14-R15-bella-donna-plates', label='Bella Donna Plate (two labels)', root_id='majolica-medals-case', root_called='plate (one of two)'),
 obj('R16', 'case B', 'east', C, 'photo and label', ['56.00', '56.50'], 'Case B, deck, left.',
     'Small gilt roundel with a crowded relief of figures round a bed and a beaded border. Matches the official photograph.',
     'Relief detail is not resolved.', '51.105', 'R16-death-of-the-virgin-51.105', label='Death of the Virgin, ca. 14..', root_id='majolica-medals-case', root_called='round medallion (one of two)'),
 obj('R17', 'case B', 'east', C, 'photo and label', ['56.00', '56.50', '57.00'], 'Case B, deck, centre, propped upright with its hanging loop at the top.',
     'Leaded glass roundel: a standing figure in a pale centre, a blue ring, and a wide border of leaves and rosettes, with a loop at the top. Matches the official photograph.',
     'The glass is seen against white and reads grey; colours are not confirmed.', '2017.29', 'R17-glass-roundel-2017.29', label='The Virgin as the Woman of the Apocalypse',
     root_id='majolica-medals-case', root_called='round medallion (one of two)'),
 obj('R18', 'case B', 'east', P, 'form only', ['56.00', '57.00'], 'Case B, deck, right, on a small tilted mount.',
     'Small upright rectangular plaque, blue with pale figures. Size and colour are consistent with the official photograph.',
     'The scene is not resolved and its label is not legible, so the match rests on form, colour and being the only such enamel plaque returned as on view.', '34.024', 'R18-enamel-plaque-34.024',
     root_id='majolica-medals-case', root_called='rectangular relief plaque'),
]
ledger = {
 'scope': 'Objects in the light Renaissance room as filmed in IMG_6383 only. Wall order and case contents are observations; nothing is measured. This ledger does not complete the room or the map.',
 'video_sha256': fm['video_sha256'],
 'axes': 'Local prototype walls as the root uses them: south = velvet and tapestry, west = shuttered window, north = doorway to the long gallery, east = tracery doorway to the medieval room. Not compass bearings.',
 'wall_order_clockwise': {'south': ['R01', 'R02'], 'west': ['R03', 'R04', 'R05'], 'north': ['R06', 'doorway to the long gallery', 'R07'], 'east': ['case A: R08-R13', 'tracery doorway', 'case B: R14-R18']},
 'cases': [
  {'id': 'R04 plinth', 'kind': 'white floor plinth with tall acrylic hood', 'holds': ['R04'], 'built_in_root': False},
  {'id': 'R05 case', 'kind': 'wall-hung white shelf with sloped label front and acrylic hood', 'holds': ['R05'], 'built_in_root': False},
  {'id': 'R06 case', 'kind': 'wall-hung white shelf with sloped label front and acrylic hood', 'holds': ['R06'], 'built_in_root': False},
  {'id': 'case A', 'kind': 'wall-hung case with white back panel, deck, sloped label front and acrylic hood', 'holds': ['R08', 'R09', 'R10', 'R11', 'R12', 'R13'], 'built_in_root': False},
  {'id': 'case B', 'kind': 'wall-hung case with white back panel, deck, sloped label front and acrylic hood', 'holds': ['R14', 'R15', 'R16', 'R17', 'R18'], 'built_in_root': False},
 ],
 'objects': objects,
 'not_artworks': [
  {'item': 'Black upholstered bench, room centre', 'built_in_root': True, 'note': 'remodel_room.gd line 964-965, dimensions unmeasured'},
  {'item': 'Low white platform along the south wall with one label stand under each textile', 'built_in_root': False},
  {'item': 'Wall labels: right of R03, both sides of R07, left of case A; a lettered sign over the north doorway; text illegible', 'built_in_root': False},
  {'item': 'White shuttered window behind R04, ceiling light tracks, ventilation grille over the north doorway', 'built_in_root': 'grille only'},
 ],
 'rejected_candidates': [
  {'slot': 'R01', 'accession': '52.110', 'title': 'Textile length, Italian, silk cut-pile velvet', 'reason': 'Official photograph shows a red, black and yellow pomegranate velvet with no stag heads. Sheet sheets/R01-rejected-textile-length-52.110.jpg.'},
  {'slot': 'R08', 'accession': '58.001 / 25.063 / 39.025 / 39.026', 'title': 'four on-view works titled Portrait of a man', 'reason': 'Egyptian and Roman, granite, marble or tempera, dated before 400; rejected on catalogue text without a photo comparison.'},
  {'slot': 'R12', 'accession': None, 'title': 'any catalogue record for the emblem book', 'reason': 'Searches for Montenay, Emblematum and Woeiriot each returned 0 rows.'},
 ],
 'root_state_read': {f: sha('/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction/' + f) for f in [
  'modules/shell/prototype/collection_reconstruction/remodel_room.gd', 'modules/shell/prototype/collection_reconstruction/prepare_remodel.py',
  'image-work/collection-room-remodel/sculpture-room-inventory.json', 'image-work/collection-room-remodel/video-inventory.json']},
 'next_asset': {'slot': 'R04', 'accession': '21.398', 'why': 'Highest priority in the brief; the only object here with an official back view; catalogue height known; filmed from three sides.',
                'muse_references': ['photos/saint-roch-21398-zoom-0.jpg', 'photos/saint-roch-21398-zoom-1.jpg', 'photos/saint-roch-21398-zoom-2.jpg', 'photos/saint-roch-21398-zoom-3.jpg'],
                'source_frames': ['frames/IMG_6383-018.30.jpg', 'frames/IMG_6383-020.60.jpg', 'frames/IMG_6383-021.30.jpg'], 'height_m': 1.054},
 'historical_2020': 'historical-2020-captions.json: 13 of the 16 matched accessions have a 2020 caption under 5th floor / European galleries; identity corroboration only, not placement',
 'all_objects_complete': False, 'geometry_installed': False, 'metric_calibration': False,
}
(here / 'ledger.json').write_text(json.dumps(ledger, indent=1, ensure_ascii=False) + '\n')
print(len(objects), 'objects;', {s: sum(o['status'] == s for o in objects) for s in (C, P, U, B)})

# REPORT.md: prose is fixed here; every catalogue field, hash and count in the tables is read from the ledger above.
api = json.loads((here / 'api/manifest.json').read_text())
L = []; w = L.append
w('# Renaissance room objects and cases (IMG_6383) — inventory for root review\n')
w('Worker report, 2026-10-01. Identification only. No source edits, no paid generation, no GPU, no Godot, no point clouds. Cost: 0 USD.\n')
w('## Result\n')
w('1. The room holds **18 objects**: 15 are confirmed against official RISD photographs, 1 is probable, 1 is known from its case label only, and 1 (the Perugino) is already built by the root.')
w('2. **Only the Perugino and the bench are built today.** All five cases and the other 17 objects are missing from the room.')
w('3. Two priority objects are not what the inventory calls them. The tall figure in front of the window is **Saint Roch, polychromed wood, 105.4 cm** (21.398), not a bronze knight. The Pietà is **Riemenschneider, linden wood** (59.128), not bronze.')
w('4. Wall order and case contents agree with the root inventory. Nothing here is measured, and the room is not complete.\n')
w('Start with `sheets/overview-wall-order.jpg`, then `sheets/labels-read.jpg` (the case labels that were legible), then one sheet per slot.\n')
w('![wall order](sheets/overview-wall-order.jpg)\n')
w('## Ledger\n')
w('Video `IMG_6383.MOV`, sha256 `' + ledger['video_sha256'] + '`. Walls are the root\'s local prototype walls, not compass bearings.\n')
w('| Slot | Where | Status | Object | Accession | Maker, date | Catalogue dimensions | Built | Seen at (s) |')
w('| --- | --- | --- | --- | --- | --- | --- | --- | --- |')
for o in objects:
    where = o['group'] if o['group'].startswith('case') else o['wall'] + ' wall'
    if 'accession' in o:
        w(f"| {o['slot']} | {where} | {o['status']} ({o['basis']}) | [{o['title']}]({o['link']}) | {o['accession']} | {o['maker']}, {o['dating']} | {o['dimensions']} | no | {', '.join(o['seen_seconds'])} |")
    elif o['status'] == B:
        w(f"| {o['slot']} | {where} | already built by root | Perugino, Madonna and Child | 16.236 | not re-examined | not re-examined | **yes** | {', '.join(o['seen_seconds'])} |")
    else:
        w(f"| {o['slot']} | {where} | **unmatched** (label only) | Emblem book, title read from the label | none found | none | none | no | {', '.join(o['seen_seconds'])} |")
w('\n"Confirmed" means the official photograph matches the object in the video in distinctive detail. "Probable" means form and colour agree but the detail is not resolved.\n')
w('## Wall order, clockwise\n')
w('- **South:** velvet R01, then tapestry R02, above one low white platform.')
w('- **West:** painting R03, the shuttered window with Saint Roch R04 on a floor plinth in front of it, then the Pietà case R05.')
w('- **North:** triptych case R06, the doorway to the long gallery, then the Perugino R07.')
w('- **East:** case A (R08–R13), the tracery doorway to the medieval room, then case B (R14–R18).')
w('- **Centre:** the bench.\n')
w('Four of the five cases hang on the wall with no floor plinth: a white shelf with a sloped label front and an acrylic hood. Only Saint Roch stands on a floor plinth.\n')
w('## What matched, and the limits\n')
for o in objects:
    if o['status'] == B: continue
    label = f" Label read: \"{o['label_read']}\"." if o['label_read'] else ''
    w(f"- **{o['slot']}** (`{o['comparison_sheet']}`), {o['observed_position']} {o['visual_evidence']}{label} Limit: {o['limits']}")
w('\nRoot inventory names corrected by this review:\n')
for o in objects:
    if o.get('accession') and o['root_inventory_called'] and o['slot'] in ('R01', 'R02', 'R03', 'R04', 'R05', 'R11'):
        w(f"- `{o['root_inventory_id']}`: \"{o['root_inventory_called']}\" is {o['title']}, {o['medium']}.")
w('\nRejected or empty leads:\n')
for r in ledger['rejected_candidates']: w(f"- {r['slot']}: {r['title']} ({r['accession'] or 'no record'}). {r['reason']}")
w('\nIn the room but not artworks:\n')
for n in ledger['not_artworks']: w(f"- {n['item']}. Built by root: {n['built_in_root']}.")
w('\n## Next asset\n')
w('**Saint Roch, 21.398.** It is the tall figure in front of the window, the first priority in the brief.\n')
w('- Give Muse the four official views `photos/saint-roch-21398-zoom-0.jpg` to `-zoom-3.jpg`. They are front, two three-quarter views and the **back**, so no surface has to be invented. All four are marked `public`.')
w('- Scale: catalogue height 1.054 m. Width and depth are not listed.')
w('- Check the result against `frames/IMG_6383-018.30.jpg`, `-020.60.jpg` and `-021.30.jpg`.')
w('- Material is dark polychromed wood with pale flesh, not bronze.')
w('- It needs a white floor plinth and a tall acrylic hood; both are unmeasured.\n')
w('The triptych R06 needs no Muse pass: it is three flat gabled panels, and the official front and back photographs can be used directly. The Pietà R05 has one usable front view, an old black-and-white view and a detail, so its back would be unobserved.\n')
w('## A second source: the 2020 faculty document\n')
h = json.loads((here / 'historical-2020-captions.json').read_text())
w(f"The root exported the museum's spring 2020 faculty planning document (`/tmp/collection-research-on-view.txt`, sha256 `{h['sha256'][:16]}…`). {len(h['entries'])} of the 16 matched accessions have a caption there, listed under \"5th floor / European galleries\"; line numbers and captions are in `historical-2020-captions.json`.\n")
w('- It agrees with the live catalogue on title, medium and size for all 13, including Saint Roch as polychromed wood and the Pietà as linden wood.')
w('- Its Pietà caption text is the same text that is legible on the case label in the video.')
w('- In 2020 the enamel plaque R18 shared a caption with the glass roundel R17, which fits the two standing side by side in case B. R18 still stays **probable**: the film does not resolve it.')
w('- Absent from it: the velvet R01, the tapestry R02 and the triptych R06 (the triptych was acquired in 2021), and nothing in it names the emblem book R12.')
w('- It is from 2020. It supports identity only and says nothing about where anything stands today.\n')
w('## Limits\n')
w('- **Nothing is measured.** Positions, case sizes, plinth and hood sizes are observations of order only. No metric calibration is claimed.')
w('- **R12** has no catalogue record, so it has no accession, size or photograph. It may be a loan. Do not build it from a guessed record.')
w('- **R18** stays probable until a sharper view or a legible label is available.')
w('- **Label text** was read from blurred 1080p frames. Titles and makers quoted above are legible; date digits mostly are not.')
w('- **On-view flag.** `onView` says an object is on display somewhere in the museum, not where.')
w('- **Rights.** Every saved photograph is marked `public` by the museum; the flag is kept per file in `photos/manifest.json`.')
w('- **Side lead, not checked:** the on-view search for "Flemish" returned two vellum miniatures about 6.7 x 5.1 cm (82.190.1, 82.190.2). They could be the unidentified works in the medieval low case. That is a text lead only; no comparison was made.\n')
w('## Provenance and checks\n')
w('| Accession | Catalogue id | Record | Record file sha256 | Primary photo | Photo sha256 |')
w('| --- | --- | --- | --- | --- | --- |')
for o in objects:
    if 'accession' in o:
        p = o['photos'][0]; w(f"| {o['accession']} | {o['catalogue_id']} | `{o['api_json']}` | `{o['api_json_sha256'][:16]}…` | `photos/{p['file']}` | `{p['sha256'][:16]}…` |")
w('\nFull hashes are in `ledger.json`, `photos/manifest.json`, `api/manifest.json`, `frames/manifest.json` and `SHA256.json`.\n')
w(f"1. **Cache first.** 13 of the 16 catalogue records were reused unchanged from the root cache (`cached-records-provenance.json` names each cache file and its hash). The root cache already held photographs of the triptych, the painting and the velvet.")
w(f"2. **Then {len(api)} free API requests** and 17 catalogue pages with {sum(len(e['photos']) for e in photos.values())} photographs, through the existing Scrapling interpreter. They found the Pietà, the cleric portrait and the book cover, which the cache did not hold.")
w(f"3. **{len(frames)} native frames** were decoded on the CPU; each decoded PNG hash and the command are in `frames/manifest.json`, with a JPEG viewing copy kept.")
w('4. `python3 check_ledger.py --self-test` **exits 0**: counts, identity flags, built-versus-missing, catalogue fields and every file hash hold, and five tampered ledgers are each caught (`check.log`).')
w('5. `git diff --check` exits 0. `scripts/check.sh` was not run: no source changed, and its Godot import would write outside this folder.')
w('6. Every sheet in `sheets/` was opened and compared by eye before a status was set.\n')
w('Rebuild: `fetch_api.py`, `fetch_photos.py`, `decode_frames.py`, `make_sheets.py`, `build_ledger.py`, `check_ledger.py` in this folder.')
(here / 'REPORT.md').write_text('\n'.join(L) + '\n')
manifest = {str(p.relative_to(here)): sha(p) for p in sorted(here.rglob('*')) if p.is_file() and p.name not in ('SHA256.json', 'check.log') and '__pycache__' not in p.parts}
(here / 'SHA256.json').write_text(json.dumps(manifest, indent=1) + '\n')
print('REPORT.md', len(L), 'lines; SHA256.json', len(manifest), 'files')
