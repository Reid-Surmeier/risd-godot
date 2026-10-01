"""Re-derives every authored number quoted in REVIEW.md from the built geometry.json and the
read-only ingestion manifests. Fails if the root rebuilds with different values (re-read the review then)."""
import hashlib, json
from pathlib import Path
ING = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
ROOT = Path('/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction/image-work/collection-room-remodel')
GEO = ING / 'main-build-rooms-v50b/collection_rooms/geometry.json'
g = json.loads(GEO.read_text())
r = {x['label']: x for x in g['rooms']}
mid = lambda s: sum(s) / 2
med, ren, grey, land = r['dark medieval room'], r['light Renaissance room'], r['grey French gallery'], r['lion stair landing']
out = {'geometry_sha256': hashlib.sha256(GEO.read_bytes()).hexdigest(),
       'same_as_v48b': hashlib.sha256((ING / 'lowpoly-room-v48b-modern-frames/geometry.json').read_bytes()).hexdigest() == hashlib.sha256(GEO.read_bytes()).hexdigest()}
# D1 landing: modern on the wall opposite medieval, sculpture on the south wall
assert set(land['openings']) == {'west', 'east', 'south'} and land['openings']['west'] == land['openings']['east'] == med['openings']['east']
out['D1_landing_openings'] = land['openings']
# D2 medieval doors not on one axis
out['D2_tracery_centre_z'], out['D2_stair_centre_z'] = mid(med['openings']['west']), mid(med['openings']['east'])
out['D2_axis_offset_m'] = round(out['D2_tracery_centre_z'] - out['D2_stair_centre_z'], 3)
assert out['D2_axis_offset_m'] == 1.715 and med['openings']['west'] == ren['openings']['east']
# D3 connector doorway centred on the grey west wall, 3.0 m from the SW corner
w, b = grey['openings']['west'], grey['bounds']
out['D3_connector_to_sw_corner_m'], out['D3_connector_to_nw_corner_m'] = round(b[3] - w[1], 3), round(w[0] - b[2], 3)
assert out['D3_connector_to_sw_corner_m'] == out['D3_connector_to_nw_corner_m'] == 3.0
assert r['purple elevator-5 connector']['openings']['west'] == r['Rockefeller']['openings']['east'] == w   # straight connector
out['D3_european_gallery_length_m'] = round(r['adjacent gallery']['bounds'][3] - r['adjacent gallery']['bounds'][2], 2)
# D4 medieval east wall: authored remainders either side of the stair door (apostle brackets z 28.75 / 31.5 in remodel_room.gd + 9.25)
e, mb = med['openings']['east'], med['bounds']
out['D4_east_wall'] = {'north_remainder_m': round(e[0] - mb[2], 2), 'south_remainder_m': round(mb[3] - e[1], 2),
                       'apostle_b_to_se_corner_m': round(mb[3] - (22.25 + 9.25), 2), 'after_D2_b_to_se_corner_m': round(mb[3] - (mid(med['openings']['west']) + .85 + .6), 3)}
assert out['D4_east_wall']['apostle_b_to_se_corner_m'] == 2.7
# coverage: ten videos, 2485 survey frames, three inventories account for all of them
man = {v['file']: v for v in json.loads((ING / 'verified-manifest.json').read_text())}
frames = {c.name: len(list(c.glob('*.jpg'))) for c in sorted((ING / 'survey-2fps').iterdir()) if c.is_dir()}
inv = {f: json.loads((ROOT / f).read_text()) for f in ['sculpture-room-inventory.json', 'european-gallery-inventory.json', 'hall-stairs-inventory.json', 'reconstruction-coverage.json']}
assert len(man) == len(frames) == 10 and sum(frames.values()) == 2485
assert inv['sculpture-room-inventory.json']['total_frames'] + inv['european-gallery-inventory.json']['total_frames'] + inv['hall-stairs-inventory.json']['reviewed_frames'] == 2485
cov = {v['video']: v for v in inv['reconstruction-coverage.json']['videos']}
for name, v in man.items():
    assert cov[name]['sha256'] == v['sha256'] and cov[name]['available_2fps_frames'] in (frames[name[:-4]], frames[name[:-4]] - 1), name
out['coverage'] = {'videos': 10, 'survey_frames': 2485, 'root_sha256_match_manifest': True,
                   'root_frame_count_off_by_one': sorted(n for n in man if cov[n]['available_2fps_frames'] != frames[n[:-4]])}
Path(__file__).with_name('check-claims.json').write_text(json.dumps(out, indent=1) + '\n')
print(json.dumps(out, indent=1))
