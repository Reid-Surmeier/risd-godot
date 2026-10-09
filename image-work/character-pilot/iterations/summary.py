"""Check that reviewed media and native receipts refer to the selected pilot ($0)."""
from pathlib import Path
import hashlib, json, subprocess

HERE = Path(__file__).resolve().parent
read = lambda name: json.loads((HERE / name).read_text())
digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
selected = digest(HERE / 'motion-diagnosis/footplant-candidate.glb')
correction = read('motion-diagnosis/correction.json')
contact = read('motion-diagnosis/contact-manifest.json')
launch = read('motion-diagnosis/correct.mcp-launch.json')
assert selected == correction['output_sha256'] == contact['candidate_sha256']
assert correction['rest_signature_unchanged'] and correction['bones'] == 24
assert launch['transport'] == 'actual MCP stdio' and launch['successfully_scheduled']
log = (HERE / 'motion-diagnosis/correct.native.log').read_text()
assert selected in log and 'Blender quit' in log
for clip in ['idle', 'walk']:
    probe = contact['contact_probe'][clip]
    assert probe['sample_count'] == 257 and probe['planar_contact_gate'] == 'PASS'
    assert probe['stance_floor_error_max_m'] < .001
    assert probe['stance_xz_drift_max_m'] < .001
    assert read(f'motion-diagnosis/candidate-proof/{clip}.json')['source_sha256'] == selected
media = {}
for name in ['walk-comparison-35', 'walk-comparison-45', 'walk-comparison-55',
             'idle-comparison-45', 'effects-control-45', 'gameview-final-45',
             'transition-grounded-45']:
    config = read(f'{name}/config.json')
    evidence = read(f'{name}/evidence.json')
    assert config['models'][-1]['sha256'] == selected and evidence['fps'] == 30
    movie = HERE / name / 'loop.mp4'
    stream = json.loads(subprocess.check_output([
        'ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries',
        'stream=avg_frame_rate,nb_frames', '-of', 'json', str(movie)]))['streams'][0]
    expected = 121 if name.startswith('idle') else 124 if name.startswith('transition') else 96
    assert stream['avg_frame_rate'] == '30/1' and int(stream['nb_frames']) == expected
    media[name] = {'sha256': digest(movie), 'fps': 30, 'frames': expected}
effects = read('effects-control-45/evidence.json')['effects']
assert effects['native_method_track_tested'] and effects['calls'] == 6
assert effects['idle_added_calls'] == 0
transition = read('transition-grounded-45/evidence.json')
assert transition['transition']['floor_gate'] == 'PASS'
original = json.loads((HERE.parent / 'hashes.json').read_text())
provider_names = ['front.png', 'mesh-output-model_glb.glb',
                  'rig-output-rigged_character_glb.glb',
                  'rig-output-animations-0-animation_glb.glb',
                  'rig-output-basic_animations-walking_glb.glb']
for name in provider_names:
    assert digest(HERE.parent / name) == original[name]
spend = json.loads((HERE.parent / 'spend.json').read_text())
liability = round(sum(entry['liability_usd'] for entry in spend['entries']), 2)
assert liability == 1.54 and liability <= spend['ceiling_usd'] == 4
result = {'selected_sha256': selected, 'native_contact': contact['contact_probe'],
          'effects': effects, 'media': media, 'additional_paid_calls': 0,
          'liability_usd': liability, 'ceiling_usd': 4,
          'scope': 'target-specific planar idle/walk prototype; owner visual acceptance pending'}
(HERE / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
print('PASS: MCP completion, contact, media, event control and spend receipts agree')
