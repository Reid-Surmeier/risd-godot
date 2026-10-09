"""Audit actual decoded samples; fps output timestamps are not source timestamps."""
import gzip
import hashlib
import json
from pathlib import Path
import re

ROOT = Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion')
OUT = ROOT/'sampling-timing-v1'
SOURCE = ROOT/'sfm-calibrated-doorway-v1'


def selected_samples(path, start):
    rows = [(int(stream), int(frame), float(pts), checksum) for stream, frame, pts, checksum
        in re.findall(r'Parsed_showinfo_(\d+).*?n:\s*(\d+).*?pts_time:([\d.\-]+).*? checksum:([A-F0-9]+)',
                      gzip.decompress(path.read_bytes()).decode())]
    streams = sorted({row[0] for row in rows})
    assert len(streams) == 2, 'Expected showinfo before and after fps.'
    decoded = {}
    for stream, _, pts, checksum in rows:
        if stream == streams[0]:
            decoded.setdefault(checksum, []).append(pts)
    result = {}
    for stream, frame, pts, checksum in rows:
        if stream == streams[1]:
            assert len(decoded[checksum]) == 1, 'Ambiguous source frame checksum.'
            result[frame+1] = dict(source_seconds=start+decoded[checksum][0],
                output_seconds=start+pts, decoded_checksum=checksum)
    assert result
    return result


survey = selected_samples(OUT/'full2.log.gz', 0)
exit_samples = selected_samples(OUT/'exit6.log.gz', 250)
entry_samples = selected_samples(OUT/'entry6.log.gz', 101)
# Verify seek/full-stream selection agreement using the decoded bitmap checksum.
for log, start, first in [('entry2', 101, 203), ('survey2', 250, 501)]:
    for frame, sample in selected_samples(OUT/(log+'.log.gz'), start).items():
        if first+frame-1 in survey:
            assert sample['decoded_checksum'] == survey[first+frame-1]['decoded_checksum']
pins = json.loads((ROOT/'heldout-calibrated-v1/audit.json').read_text())['source_sha256']
assert all(hashlib.sha256((SOURCE/p).read_bytes()).hexdigest() == h for p, h in pins.items())
registered = json.loads((SOURCE/'result.json').read_text())[0]['registered']
leaks = []
for query in [506, 516]:
    for name in registered:
        if name.startswith('IMG_6380_exit6fps/'):
            frame = int(Path(name).stem)
            gap = abs(exit_samples[frame]['source_seconds']-survey[query]['source_seconds'])
            if gap <= .2:
                leaks.append(dict(query=f'IMG_6380/{query:06}.jpg', reference=name,
                    source_gap_seconds=gap, query_sample=survey[query], reference_sample=exit_samples[frame]))
entry = [dict(frame=frame, sample=entry_samples[frame],
    query_sample=survey[206], source_gap_seconds=abs(entry_samples[frame]['source_seconds']-survey[206]['source_seconds']),
    passes_exclusion=abs(entry_samples[frame]['source_seconds']-survey[206]['source_seconds']) > .2)
    for frame in [12, 14]]
# Runnable negative control: output times pass while decoded sample separation fails.
assert abs(entry_samples[12]['output_seconds']-survey[206]['output_seconds']) > .2
assert not entry[0]['passes_exclusion'] and entry[1]['passes_exclusion']
assert {row['query'] for row in leaks} == {'IMG_6380/000506.jpg', 'IMG_6380/000516.jpg'}
split = json.loads((ROOT/'heldout-calibrated-v1/audit.json').read_text())['split_point_results']
affected = {row['query'] for row in leaks}
report = dict(source_sha256=pins, original_split_point_supported=sum(row['supported'] for row in split),
    supported_after_temporal_exclusion=sum(row['supported'] and row['image'] not in affected for row in split),
    temporal_exclusion_passed=not leaks, exclusion_half_width_seconds=.2,
    registered_reference_leaks=leaks, grand_reference_samples=entry,
    grand_reference_exclusion_passed=all(row['passes_exclusion'] for row in entry),
    log_sha256={p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in OUT.glob('*.log.gz')},
    provider='Local ffmpeg CUDA NVDEC/scale_cuda; CPU checksum audit', cost_usd=0,
    caveat='Frozen model unchanged. Corrects only the additional 6fps sampling gate. '
        'Same-video neighbours remain correlated; even temporally separated queries are not independent captures. '
        'Do not overwrite historical holdout results or accept navigation from this diagnostic.')
(OUT/'result.json').write_text(json.dumps(report, indent=2)+'\n')
excluded = {row['reference'] for row in leaks}
selection = dict(source_sha256=pins, training_names=[name for name in registered if name not in excluded],
    excluded_names=sorted(excluded), heldout_names=[row['image'] for row in split],
    requirement='Fresh disposable reconstruction from cached matches with an explicit image allowlist; '
        'do not seed it with points or poses fitted to excluded images.',
    rebuilt=False, navigation_accepted=False)
assert len(selection['training_names']) == 473
(OUT/'strict-training-selection.json').write_text(json.dumps(selection, indent=2)+'\n')
print(json.dumps(report, indent=2))
