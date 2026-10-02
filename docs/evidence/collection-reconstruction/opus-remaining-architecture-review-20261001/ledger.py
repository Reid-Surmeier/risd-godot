"""Coverage ledger for all ten videos: what the root files say, what this review looked at, and where they differ."""
import hashlib, json, re
from pathlib import Path
ING = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
ROOT = Path('/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction/image-work/collection-room-remodel')
HERE = Path(__file__).parent
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
man = {v['file'][:-4]: v for v in json.loads((ING / 'verified-manifest.json').read_text())}
ENLARGED = {  # frames opened at 480x853 in frames/*.jpg
 'IMG_6378': [], 'IMG_6379': [340, 344, 346], 'IMG_6381': [169, 181, 185], 'IMG_6385': [],
 'IMG_6380': [19, 29, 31, 33, 35, 37, 69, 71, 73, 75, 77, 79, 199, 203, 205, 207, 213, 217, 239, 243, 245, 247, 261, 267, 321, 337, 427, 449, 453, 457, 459, 471, 479, 493, 497, 499],
 'IMG_6382': [1, 13, 27, 29, 33, 37, 41, 47, 49, 53, 57, 61, 155, 157, 159, 163, 165, 167],
 'IMG_6383': [3, 121, 123, 125, 127, 129, 131, 132, 133, 134, 135, 139, 141, 145, 147],
 'IMG_6384': [25, 29, 33, 37, 43, 47], 'IMG_6386': [141, 153, 177, 197, 205, 209],
 'IMG_6387': [7, 9, 11, 13, 15, 17, 19, 20, 21, 23, 27, 75, 79, 83, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 165, 167, 171]}
NOTES = {
 'IMG_6378': ('hall-stairs-inventory.json', 'Metcalf Auditorium only: raked seating, stage and lectern, side steps, rear ramp, booth, exit lobby.', 'Agrees with root. No filmed connection to any other room; nothing to place in the loop.', 'not built; no connection evidence'),
 'IMG_6379': ('hall-stairs-inventory.json', 'Skylit piano stair hall: level 4 with piano and purple lift 4, flights up, wall works, upper landing, door into the grey gallery (162.5-178.5 s).', 'Agrees with root. Adds: through the piano door the Grand Gallery doorway is on axis and the connector doorway is at the far end of the right wall (171.5 s) - see D3.', 'threshold stub only'),
 'IMG_6380': ('hall-stairs-inventory.json + video-inventory.json + grey-frames-source-fit.json', 'Grey French gallery (0-49 s, 78-100 s), marble stair hall and fireplace (30-36 s, 43-78 s), Grand Gallery doorway (98-106 s), purple connector (101-103 s, 119-121 s, 240-250 s), Rockefeller (121-239 s), first look down the European gallery (258-260 s).', 'Wall order agrees with root. Geometry does not: D3 (connector doorway position). Rockefeller wall assignment checked and matches the authored room.', 'grey room, connector and Rockefeller built; marble stair is a stub'),
 'IMG_6381': ('hall-stairs-inventory.json', 'Marble stair from the hall beside the grey gallery up to an upper landing: chandelier, arched triple window, two doors to case galleries; back down to the Ionic opening (84-98 s).', 'Agrees with root. Adds a fourth view of D3 from the stair (90.0 s). Upper level rooms are thresholds only and not connected to anything else filmed.', 'stub only'),
 'IMG_6382': ('sculpture-room-inventory.json + medieval-panel-source-fit.json + magdalene-frame-source-fit.json', 'Medieval room, complete circuit clockwise from the portal, then two wide pans (77-93 s) and the tall case (99-112 s).', 'Wall assignment agrees with root. Geometry: D2 and D4. Eight wall or floor objects seen are not built (listed in REVIEW.md).', 'shell, portal, grille, 4 panels, 2 apostles, 2 case shells built'),
 'IMG_6383': ('sculpture-room-inventory.json + perugino-frame-source-fit.json', 'Renaissance room, complete circuit, then a full wide pan (60-73 s). Tracery doorway seen from this side at 1.0 and 66.0 s.', 'Wall assignment agrees with root. Only the Perugino, bench, window, plinth and vent are built; nine object groups are not.', 'shell built; objects mostly missing'),
 'IMG_6384': ('european-gallery-inventory.json', 'European gallery from the far (Renaissance) end back to the Rockefeller door: far end wall and both long walls.', 'Wall order agrees except D5: two far-wall display groups have east and west swapped, and the Previtali is on the far end wall.', 'shell and some objects built'),
 'IMG_6385': ('european-gallery-inventory.json + video-inventory.json', 'European gallery from the Rockefeller door: dress case in the corner left of the door, print, secretary, prints, Delacroix, silver case.', 'Agrees with root: these are on the west wall.', 'secretary built'),
 'IMG_6386': ('european-gallery-inventory.json + goltzius-source-fit.json', 'European gallery west wall and cases, long views both ways (70-88 s), far doorway and the walk through into the Renaissance room (98-106 s).', 'Agrees with root, including two door leaves opening into the Renaissance room.', 'shell and some objects built'),
 'IMG_6387': ('hall-stairs-inventory.json + modern-frames-source-fit.json', 'Lion landing, two pans (1-11 s, 41-45 s), stairwell (13-34 s), sculpture door (35-39 s), walk into the modern gallery and a full pan (45.5-85 s).', 'Does NOT agree with root: D1. Root has the modern door opposite the medieval door and the sculpture door on the adjoining south wall.', 'landing and modern room built on the wrong walls; sculpture gallery is a stub'),
}
sheets = {}
for p in sorted((HERE / 'sheets').glob('*.jpg')):
    clip, a, b, step = re.match(r'(IMG_\d+)-(\d+)-(\d+)-step(\d+)', p.name).groups()
    sheets.setdefault(clip, []).append({'file': 'sheets/' + p.name, 'sha256': sha(p), 'frames': list(range(int(a), int(b) + 1, int(step)))})
videos = []
for clip in sorted(man):
    v = man[clip]; n = len(list((ING / 'survey-2fps' / clip).glob('*.jpg')))
    seen = sorted({f for s in sheets[clip] for f in s['frames']} | set(ENLARGED[clip]))
    root_files, saw, verdict, built = NOTES[clip]
    videos.append({'video': clip + '.MOV', 'sha256': v['sha256'], 'seconds': float(v['metadata']['format']['duration']), 'survey_2fps_frames': n,
                   'root_files': root_files, 'root_says_all_frames_reviewed': True,
                   'this_review': {'frames_looked_at': len(seen), 'share_of_survey': round(len(seen) / n, 2), 'sheets': [{k: s[k] for k in ('file', 'sha256')} for s in sheets[clip]],
                                   'enlarged_frames': ENLARGED[clip], 'enlarged_frame_sha256': {f'{f:06d}.jpg': sha(ING / 'survey-2fps' / clip / f'{f:06d}.jpg') for f in ENLARGED[clip]}},
                   'rooms_seen': saw, 'reconciliation': verdict, 'built_in_v50b': built})
out = {'date': '2026-10-01', 'survey': 'survey-2fps, 1280x720, frame N at (N-1)/2 s, rotated upright for viewing only',
       'total_survey_frames': sum(v['survey_2fps_frames'] for v in videos), 'frames_looked_at': sum(v['this_review']['frames_looked_at'] for v in videos),
       'limit': 'This review sampled every second frame of 6380/6382/6383/6387 and every fourth to eighth frame of the rest. It is a check on topology and wall order, not a second full object inventory.',
       'root_files_sha256': {f: sha(ROOT / f) for f in ['reconstruction-coverage.json', 'video-inventory.json', 'european-gallery-inventory.json', 'hall-stairs-inventory.json', 'sculpture-room-inventory.json', 'grey-frames-source-fit.json', 'modern-frames-source-fit.json', 'medieval-panel-source-fit.json', 'goltzius-source-fit.json', 'magdalene-frame-source-fit.json', 'perugino-frame-source-fit.json']},
       'videos_without_any_source_fit_file': ['IMG_6378.MOV', 'IMG_6379.MOV', 'IMG_6381.MOV', 'IMG_6384.MOV', 'IMG_6385.MOV'],
       'videos': videos}
(HERE / 'ledger.json').write_text(json.dumps(out, indent=1) + '\n')
for v in videos: print(v['video'], v['survey_2fps_frames'], v['this_review']['frames_looked_at'], v['this_review']['share_of_survey'])
print(out['total_survey_frames'], out['frames_looked_at'])
