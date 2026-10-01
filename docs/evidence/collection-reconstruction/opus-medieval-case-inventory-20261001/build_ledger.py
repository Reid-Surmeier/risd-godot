"""Assemble ledger.json from the hand-recorded observations below plus hashes read from api/, photos/ and frames/ manifests."""
import hashlib, json
from pathlib import Path
here = Path(__file__).parent
api = {m['file']: m for m in json.loads((here / 'api/manifest.json').read_text())}
photos = {e['accession']: e for e in json.loads((here / 'photos/manifest.json').read_text())}
frames = {f"{f['seconds']:.2f}": f for f in json.loads((here / 'frames/manifest.json').read_text())['frames']}
def matched(slot, acc, cid, status, tier, seen, slot_desc, evidence, sheet, limits):
    r = json.loads((here / f'api/id-{cid}.json').read_text())[0]; assert r['objectNumber'] == acc
    return {'slot': slot, 'case': 'tall', 'status': status, 'confidence_tier': tier, 'accession': acc, 'catalogue_id': cid, 'title': r['title'], 'maker': r['primaryMaker'],
            'dating': f"{r['datingYearFrom']}-{r['datingYearTo']}", 'medium': '; '.join(r['medium']), 'dimensions': r['dimensions'], 'place': r['place'], 'credit': r['credit'],
            'on_view_flag': r['onView'], 'link': r['url'], 'api_json': f'api/id-{cid}.json', 'api_url': api[f'id-{cid}.json']['url'], 'api_json_sha256': api[f'id-{cid}.json']['sha256'],
            'photos': [{k: p[k] for k in ('file', 'url', 'asset_copyright', 'sha256')} for p in photos[acc]['photos']],
            'video': 'IMG_6382.MOV', 'seen_seconds': seen, 'source_frames': [{'seconds': float(s), 'png_sha256': frames[s]['png_sha256'], 'kept_file': 'frames/' + frames[s]['kept_file']} for s in seen],
            'visible_slot': slot_desc, 'visual_evidence': evidence, 'comparison_sheet': f'sheets/{sheet}.jpg', 'limits': limits}
T = ['102.20', '103.70', '105.70', '107.30', '108.90', '110.50', '111.70', '112.90']
ledger = {
 'scope': 'Contents of the two medieval-room glass cases in IMG_6382 only. Positions are source-relative and provisional; this ledger does not complete the room.',
 'video_sha256': json.loads((here / 'frames/manifest.json').read_text())['video_sha256'],
 'axes': 'Local prototype axes from background landmarks (stair door = east, tracery door = west, portal = north, Christ head wall = south). Not museum compass bearings; unaccepted.',
 'objects': [
  matched('T1', '15.108', '1388871', 'confirmed', 'A', ['102.20', '105.70', '108.90', '110.50', '111.70', '112.90'], 'West end of deck on the tall white block riser, facing west (away from the stair door).',
          'Seated Virgin with long hair and circlet, blue bodice under gold-brown mantle; Child on her right knee turned to an open book on her lap; stepped base. Front, both sides and back are filmed.', 'T1-virgin-and-child-15.108',
          'Back is filmed only blurred at 105.70s (dark green, flat); the four saved official photos show front and three-quarter/side views, not the back.'),
  matched('T2', '2020.55', '1557221', 'confirmed', 'A', ['102.20', '105.70', '108.90', '110.50'], 'Centre of deck on a low white plinth; one Christ roundel faces north and one faces south, a sailing-boat panel faces east.',
          'Bright metal domed lid with ring finial, cylindrical body with blue-and-white lattice, roundel of Christ crowned with thorns in a red robe, the words GOD SAVE THE QUEENS legible at 110.50s, blue Delft-style sailing boat panel at 105.70s, skirted base on four scroll feet.', 'T2-god-save-the-queens-2020.55',
          'Official photos are marked in_copyright (artist 1994-1997): reference only, not a texture source without the owner clearing it. The west face of the body is not filmed.'),
  matched('T3', '40.002', '1443596', 'confirmed', 'A', ['102.20', '105.70', '107.30', '112.90'], 'South-east quarter of deck, free-standing on the deck surface.',
          'Gilt tower monstrance: crocketed open spire with finial, glazed central chamber with flying buttresses and pinnacles, two knops on the stem, wide lobed star foot.', 'T3-monstrance-40.002',
          'Fine tracery and foot engraving are not resolved in the 1080p source.'),
  matched('T4', '1992.051', '1550551', 'confirmed', 'B', ['102.20', '103.70', '105.70', '107.30', '110.50'], 'East end of deck, north-east corner, standing on the deck surface.',
          'Plain flared silver beaker with everted lip, twisted rope collar above a stepped spreading foot; height consistent with 14 cm beside the 8.9 cm pyx. Two other on-view cups were compared and rejected by shape (Kiddush Cup 2016.17 is a stemmed goblet; Beaker 1991.033 is a dark straight tumbler).', 'T4-communion-beaker-1992.051',
          'The engraved scrollwork and figure medallion on the body are not resolved in the source, so the match rests on form, the rope collar and being the only such beaker returned as on view.'),
  matched('T5', '30.011', '1230716', 'confirmed', 'B', ['102.20', '103.70', '105.70', '107.30', '110.50'], 'East-centre of deck between the monstrance and the beaker, on the deck surface.',
          'Small round box with conical lid, cross finial on a knob, hinge and clasp lugs at the rim; proportions match the 8.9 cm catalogue pyx.', 'T5-pyx-30.011',
          'Enamel quatrefoils and blue ground are washed out to grey in the source; match rests on form, hardware and being the only pyx returned as on view.'),
  matched('T6', '2014.110', '1197491', 'confirmed', 'B', ['102.20', '103.70', '105.70', '107.30'], 'North edge of deck, east of centre, lying on a low white wedge tilted toward the north viewer; feet toward the north edge, head toward the deck centre.',
          'Narrow ivory relief figure about 2.5 times taller than wide: rounded head with nimbus outline, shoulders, horizontal bands at the chest, book-side projection at mid-height, two feet on a small base. Proportion matches 15.9 x 6.4 cm.', 'T6-christ-in-majesty-2014.110',
          'Face and drapery detail are not resolved; match rests on silhouette, colour, proportion and being the only single-figure medieval ivory returned as on view. Back is unseen (object lies on its mount).'),
  matched('T7', '52.002', '1211626', 'confirmed', 'A', ['102.20', '103.70', '105.70', '107.30', '111.70'], 'North-west, raised on a thin rod stand just north of the Virgin riser, relief facing north.',
          'Pointed-arch shell plaque with white relief figures on a blue-grey ground inside a metal rim; the dark silver back with its handle is seen from the south-east at 107.30s.', 'T7-pax-52.002',
          'Relief subject is not resolved in the source beyond white figures on blue under an arch.'),
  {'slot': 'L1', 'case': 'low', 'status': 'unidentified', 'video': 'IMG_6382.MOV', 'seen_seconds': ['0.00', '95.10', '96.94', '97.70'],
   'visible_slot': 'East half of the raised white deck (left when read from the north label side), on a small cream mount.',
   'visual_evidence': 'Very small upright work on paper, a few centimetres across: a pale central form on a darker ground with a light border, on a cream mount much larger than the image.',
   'comparison_sheet': 'sheets/L-low-case-prints-unidentified.jpg', 'limits': 'Subject, technique and label text are unreadable at native resolution. No catalogue candidate could be compared.'},
  {'slot': 'L2', 'case': 'low', 'status': 'unidentified', 'video': 'IMG_6382.MOV', 'seen_seconds': ['0.00', '95.10', '96.94', '97.70'],
   'visible_slot': 'West half of the raised white deck (right when read from the north label side), on a larger cream sheet.',
   'visual_evidence': 'Monochrome image slightly wider than tall, roughly three times the width of L1: a dark-toned scene with a seated or half-length figure with bowed head on the right and a second form on the left.',
   'comparison_sheet': 'sheets/L-low-case-prints-unidentified.jpg', 'limits': 'Subject, technique and label text are unreadable at native resolution. No catalogue candidate could be compared.'},
 ],
 'not_artworks': [
  {'case': 'tall', 'item': 'Display furniture: tall white block (T1), low white plinth (T2), white wedge (T6), thin rod stand (T7), raised white deck with sloped apron.'},
  {'case': 'tall', 'item': 'Printed label panels on the sloped apron on at least the north, east and west sides; text illegible.'},
  {'case': 'tall', 'item': 'Small grey block at the foot of the T1 riser (105.70s); probably a case sensor, unverified.'},
  {'case': 'low', 'item': 'Two printed label groups on the north edge of the deck, each a heading with a text block; text illegible.'},
 ],
 'rejected_candidates': [
  {'slot': 'T4', 'accession': '2016.17', 'title': 'Kiddush Cup', 'reason': 'Stemmed goblet with bulbous bowl; source is a footed flared beaker.'},
  {'slot': 'T4', 'accession': '1991.033', 'title': 'Beaker (Pat Flynn)', 'reason': 'Dark straight-sided tumbler with no foot or collar.'},
  {'slot': 'L1/L2', 'accession': '2010.19.1', 'title': 'Baptism of Christ (Master of Monza), watercolor on vellum, 9.2 x 7.3 cm', 'reason': 'Text-only lead from the existing cache; catalogue flag onView is false and no visual comparison is possible. Not a match.'},
 ],
}
(here / 'ledger.json').write_text(json.dumps(ledger, indent=1, ensure_ascii=False) + '\n')
print(len(ledger['objects']), 'objects;', sum(o['status'] == 'confirmed' for o in ledger['objects']), 'confirmed')

# REPORT.md: prose is fixed here; every hash, link and catalogue field in the tables is read from the ledger above.
ok = [o for o in ledger['objects'] if o['status'] == 'confirmed']
onview = [m for m in api.values() if 'field_on_view=1' in m['url']]
onview_rows = [x for m in onview for x in json.loads((here / 'api' / m['file']).read_text())]
assert all(x['onView'] for x in onview_rows)
L = []; w = L.append
w('# Medieval glass cases: object ledger (IMG_6382)\n')
w('2026-10-01. Contents identification only, for Collection issues 178/181/182/183. No paid generation, no GPU, no point clouds, no source edits. Spend: 0 USD.\n')
w('## Result\n')
w('1. **Tall case** (stair-door side): 7 objects seen, all 7 matched to RISD catalogue records by side-by-side comparison with official photographs.')
w('2. **Low table case**: 2 small matted works on paper seen, both **unidentified**. The footage cannot resolve their subject or labels and no catalogue candidate could be compared.')
w('3. The existing inventory text was wrong for both cases: the low case holds two small works on paper, not "two large narrative relief plaques"; the tall case holds seven objects, not four, and one of them is a 1990s ceramic.')
w('4. This does not complete the room. Case sizes, object positions and scale stay provisional and belong to the root and the other workers.\n')
w('Start with `sheets/overview-slots.jpg` (slot ids on the source frames), then one sheet per slot.\n')
w('## Ledger\n')
w('Video `IMG_6382.MOV`, sha256 `' + ledger['video_sha256'] + '`. Axes are the local prototype axes (stair door east, tracery door west, portal north), not compass bearings.\n')
w('| Slot | Status | Object | Accession | Maker, date | Medium | Catalogue dimensions | Seen at (s) | Where in the case |')
w('| --- | --- | --- | --- | --- | --- | --- | --- | --- |')
for o in ledger['objects']:
    if o['status'] == 'confirmed':
        w(f"| {o['slot']} | confirmed, tier {o['confidence_tier']} | [{o['title']}]({o['link']}) | {o['accession']} | {o['maker']}, {o['dating']} | {o['medium']} | {o['dimensions']} | {', '.join(o['seen_seconds'])} | {o['visible_slot']} |")
    else:
        w(f"| {o['slot']} | **unidentified** | Work on paper | none | unknown | unknown | unknown | {', '.join(o['seen_seconds'])} | {o['visible_slot']} |")
w('\nTier A: distinctive surface detail matches the official photograph. Tier B: form, proportion and hardware match and it is the only such object the catalogue returns as on view, but the surface decoration is not resolved in the 1080p source.\n')
w('## What matched, and what did not\n')
for o in ledger['objects']:
    w(f"- **{o['slot']}** (`{o['comparison_sheet']}`): {o['visual_evidence']} Limit: {o['limits']}")
w('\nRejected or unverified leads:\n')
for r in ledger['rejected_candidates']: w(f"- {r['slot']}: {r['title']} ({r['accession']}). {r['reason']}")
w('\nIn the cases but not artworks:\n')
for n in ledger['not_artworks']: w(f"- {n['case'].capitalize()} case: {n['item']}")
w('\n## Limits\n')
w('- **Low case identities are open.** The root review calls the two works manuscript leaves; at native resolution I can only confirm two monochrome images on cream mounts. A legible label photo or a closer frame is needed. Do not build them from a guessed catalogue record.')
w('- **Unseen surfaces.** Not filmed: the underside of every object, the back of the ivory (T6), the west face of the ceramic (T2). The back of the Virgin (T1) is filmed only blurred. The tall case was filmed from all four sides, the low case from its north and south sides only.')
w('- **Occlusion.** No slot in either case appears empty or hidden in any frame, but an object smaller than about 2 cm would not be resolved.')
w('- **On-view flag.** The catalogue `onView` value says an object is on display somewhere in the museum, not in which case. Placement here rests on the photo comparison.')
w('- **Positions and scale** are source-relative. Nothing here was measured.')
w('- **Rights.** The T2 photographs are marked `in_copyright` by the museum; the other six are marked `public`. Use T2 photos as reference only until the owner decides.\n')
w('## For the low-polygon build\n')
w('Catalogue sizes in metres, for scale only: T1 height 0.394; T2 0.33 x 0.16 x 0.16; T3 height 0.464; T4 height 0.14; T5 height 0.089; T6 0.159 x 0.064; T7 0.121 x 0.089 x 0.022. Widths and depths not listed are not in the catalogue and must not be invented as measured.')
w('Suggested forms: T2, T4 and T5 are lathe shapes; T3 is a lathe stem and lobed foot with an open tower; T6 and T7 are thin reliefs on a wedge and a rod stand; T1 needs a real sculpt pass from the four official views.\n')
w('## Provenance\n')
w('| Accession | Catalogue id | API JSON | API JSON sha256 | Primary photo | Photo sha256 |')
w('| --- | --- | --- | --- | --- | --- |')
for o in ok:
    p = o['photos'][0]; w(f"| {o['accession']} | {o['catalogue_id']} | `{o['api_json']}` | `{o['api_json_sha256']}` | `photos/{p['file']}` | `{p['sha256']}` |")
w('\nEvery saved photograph, page and query has its URL and sha256 in `photos/manifest.json` and `api/manifest.json`; `ledger.json` carries the full record per slot.\n')
w('| Frame (s) | Decoded PNG sha256 | Kept viewing copy |')
w('| --- | --- | --- |')
for k in sorted(frames, key=float): w(f"| {k} | `{frames[k]['png_sha256']}` | `frames/{frames[k]['kept_file']}` |")
w('\nFrames were CPU-decoded with the command recorded in `frames/manifest.json`. The 78.25, 88.75 and 96.25 s hashes equal the root\'s `main-worker-medieval-cases-20261001T0525/source-hashes.json`, so these are the same frames the root reviewed. The 10 MB PNGs are not kept; rerun the command to reproduce them. Three distant doorway views from IMG_6387 and IMG_6383 are in `sheets/adjacent-doorway-views.jpg` and `frames/adjacent-manifest.json`; they corroborate where the cases stand and add no objects.\n')
w('## Method and checks\n')
w('1. Read the existing catalogue caches first (4,134 cached records). They already held T1, T5, T6 and T7 as on-view candidates.')
w(f"2. Then {len(api)} free API requests ({len(onview)} with `field_on_view=1`, 7 by id) and 9 catalogue pages with {sum(len(e['photos']) for e in photos.values())} photographs, through the Scrapling Fetcher the root already uses; plain `curl` gets a Cloudflare 403. Queries stopped when the coordinator asked.")
w(f"3. Passed: all {len(onview_rows)} rows returned by on-view queries have `onView` true; all 7 by-id records match the accession they were fetched for; three frame hashes equal the root's.")
w('4. Not verified: the `field_on_view` parameter name comes from the root research note citing the official API documentation, which I did not re-read; only its behaviour was checked. Label text in both cases. Any metric position.')
w('5. `git diff --check` passes. `scripts/check.sh` was not run: its Godot import step would write `.import` files beside pending files outside this folder, which this task may not touch. No source changed.\n')
w('Rebuild: `fetch_api.py`, `fetch_photos.py`, `decode_frames.py`, `make_sheets.py`, `build_ledger.py` in this folder.')
(here / 'REPORT.md').write_text('\n'.join(L) + '\n'); print('REPORT.md', len(L), 'lines')
