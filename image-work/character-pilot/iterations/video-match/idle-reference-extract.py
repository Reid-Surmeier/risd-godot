# Forward kinematics of ac-decomp player skeleton (boy_model.c joint table) for a player_anim.c clip.
# Conventions verified at 09ca8e8b: c_keyframe.c play() (root trans xyz, then per-joint rot xyz; value*0.1 deg),
# draw: child = parent * T(trans) * Rz * Ry * Rx (sys_matrix.c Matrix_softcv3_mult), non-root trans = joint table.
import re, sys, math, json, hashlib
from pathlib import Path
source_dir = Path(sys.argv[1])
output_dir = Path(__file__).resolve().parent
anim_src = (source_dir / 'player_anim.c').read_text()
model_src = (source_dir / 'boy_model.c').read_text()
def arr(src, name):
    m = re.search(r'(?:u8|s16)\s+' + re.escape(name) + r'\[\]\s*=\s*\{(.*?)\};', src, re.S)
    return [int(x) for x in re.findall(r'-?\d+', m.group(1))]
def s16(v): return v - 65536 if v > 32767 else v
jt = re.search(r'cKF_Joint_R_c cKF_je_r_boy_1_tbl\[\] = \{(.*?)\n\};', model_src, re.S).group(1)
joints = [(int(c), (s16(int(x)), s16(int(y)), s16(int(z)))) for c, x, y, z in
          re.findall(r'\{\s*\w+,\s*(\d+),\s*\w+,\s*\{\s*(\d+),\s*(\d+),\s*(\d+)\s*\}\s*\}', jt)]
def hermite(t, tension, p0, p1, m0, m1):
    t2, t3 = t*t, t*t*t
    pos = -(t3*2) + 3*t2
    return (1-pos)*p0 + pos*p1 + tension*((t + (t3 - 2*t2))*m0 + (t3 - t2)*m1)
def keycalc(keys, frame):
    if keys[0][0] >= frame: return keys[0][1]
    if keys[-1][0] <= frame: return keys[-1][1]
    for (f0, v0, m0), (f1, v1, m1) in zip(keys, keys[1:]):
        if f1 > frame:
            d = f1 - f0
            return int(hermite((frame - f0)/d, d/30.0, v0, v1, m0, m1) + 0.5) if d else v0
def channels(clip, frame):
    m = re.search(r'cKF_Animation_R_c\s+cKF_ba_r_' + clip + r'\s*=\s*\{(.*?)\};', anim_src, re.S)
    parts = [p.strip() for p in m.group(1).split(',')]
    flags, data, keyn, const = (arr(anim_src, p) for p in parts[:4])
    di = ki = ci = 0; vals = []
    def take(flagged):
        nonlocal di, ki, ci
        if flagged:
            n = keyn[ki]; tr = data[di*3:(di+n)*3]; di += n; ki += 1
            return keycalc([tuple(tr[i:i+3]) for i in range(0, len(tr), 3)], frame)
        v = const[ci]; ci += 1; return v
    root = [take(flags[0] & b) for b in (32, 16, 8)]
    rots = [[take(flags[i] & b) for b in (4, 2, 1)] for i in range(len(joints))]
    return root, rots
def mat_mul(a, b): return [[sum(a[i][k]*b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]
def T(x, y, z): return [[1,0,0,x],[0,1,0,y],[0,0,1,z],[0,0,0,1]]
def R(axis, deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return {'x': [[1,0,0,0],[0,c,-s,0],[0,s,c,0],[0,0,0,1]], 'y': [[c,0,s,0],[0,1,0,0],[-s,0,c,0],[0,0,0,1]],
            'z': [[c,-s,0,0],[s,c,0,0],[0,0,1,0],[0,0,0,1]]}[axis]

PIN = '09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c'
template_path = output_dir / 'walk-reference-curves.json'
template = json.loads(template_path.read_text())
assert template['source_commit'] == PIN
hierarchy = template['joint_hierarchy']
assert len(hierarchy) == len(joints) == 26
pending = []
for n, (children, trans) in enumerate(joints):
    while pending and pending[-1][1] == 0:
        pending.pop()
    parent = pending[-1][0] if pending else None
    if pending:
        pending[-1][1] -= 1
    assert hierarchy[n]['parent'] == parent
    assert hierarchy[n]['children'] == children
    assert hierarchy[n]['translation'] == list(trans)
    pending.append([n, children])

# Degree channels in the established reference already include source binangle
# truncation; sin/cos use Python math, not GameCube lookup tables.
def pose(clip, frame, phase):
    root, raw = channels('ply_1_' + clip, frame)
    angles = [[s16(int(v * 0.1 * (65536.0 / 360.0))) * (360.0 / 65536.0)
               for v in xyz] for xyz in raw]
    local, glob = [], []
    for n, (rx, ry, rz) in enumerate(angles):
        trans = root if n == 0 else joints[n][1]
        m = mat_mul(mat_mul(mat_mul(T(*trans), R('z', rz)), R('y', ry)), R('x', rx))
        local.append(m)
        parent = hierarchy[n]['parent']
        glob.append(m if parent is None else mat_mul(glob[parent], m))
    return dict(phase=phase, source_frame=frame, local_euler_xyz_degrees=angles,
                local_matrices_row_major=local, global_matrices_row_major=glob,
                global_joint_positions=[[m[0][3], m[1][3], m[2][3]] for m in glob])

# Guard the established public seam with all existing WALK1 samples, not a
# separately invented hierarchy or axes convention.
maximum_error = 0.0
for known in template['samples']:
    generated = pose('walk1', known['source_frame'], known['phase'])
    for field in ('local_euler_xyz_degrees', 'local_matrices_row_major',
                  'global_matrices_row_major', 'global_joint_positions'):
        def numbers(value):
            if isinstance(value, list):
                for item in value:
                    yield from numbers(item)
            else:
                yield value
        maximum_error = max(maximum_error, max(abs(a-b) for a,b in zip(
            numbers(generated[field]), numbers(known[field]))))
assert maximum_error < 1e-8, maximum_error

result = {key: value for key, value in template.items()}
descriptor = re.search(r'cKF_Animation_R_c\s+cKF_ba_r_ply_1_wait1\s*=\s*\{(.*?)\};', anim_src, re.S)
assert int(descriptor.group(1).split(',')[-1]) == 33
result.update(animation='wait1', authored_cycle_phase_intervals=32,
              source_effect_phases={}, runtime_phase_speed_formula='0.5 source frames/update; approximately 60 updates/s; 32 intervals / 30 frames/s = 1.0666666666666667 s')
result['samples'] = [pose('wait1', 1 + 32*i/128, i/128) for i in range(129)]
flags = arr(anim_src, 'cKF_ckcb_r_ply_1_wait1_tbl')
result['channels'] = []
for i, label in enumerate([('root_translation_' + axis) for axis in 'XYZ'] +
                         [j['name'] + '_' + axis for j in hierarchy for axis in 'XYZ']):
    if i < 3:
        values = [s['global_joint_positions'][0][i] for s in result['samples']]
        flagged = flags[0] & (32 >> i)
    else:
        joint, axis = divmod(i-3, 3)
        values = [s['local_euler_xyz_degrees'][joint][axis] for s in result['samples']]
        flagged = flags[joint] & (4 >> axis)
    result['channels'].append(dict(label=label, animated=bool(flagged),
        range=[min(values), max(values)], phase_0_quarter_half_threequarters=[values[n] for n in (0,32,64,96)]))

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
for item in template['source_inputs']:
    assert digest(source_dir / Path(item['path']).name) == item['sha256']
curve_path = output_dir / 'idle-reference-curves.json'
curve_path.write_text(json.dumps(result, separators=(',', ':')) + '\n')

# Kinematic ranges in the original Y-up/+Z-forward model space. Frontal
# abduction and sagittal drive are independent projections, not Euler axes.
def span(values):
    return dict(min=min(values), max=max(values), peak_to_peak=max(values)-min(values))
metrics = dict(root_bob_model_units=span([s['global_joint_positions'][0][1] for s in result['samples']]),
               root_sway_forward_model_units=span([s['global_joint_positions'][0][2] for s in result['samples']]),
               base_sway_degrees=span([s['local_euler_xyz_degrees'][1][1] for s in result['samples']]), arms={})
for side, shoulder, distal in [('Left',15,16), ('Right',18,19)]:
    frontal, sagittal = [], []
    for sample in result['samples']:
        points = sample['global_joint_positions']
        v = [points[distal][k]-points[shoulder][k] for k in range(3)]
        frontal.append(math.degrees(math.atan2(abs(v[0]), -v[1])))
        sagittal.append(math.degrees(math.atan2(v[2], -v[1])))
    metrics['arms'][side] = dict(frontal_abduction_degrees=span(frontal), sagittal_drive_degrees=span(sagittal))
hip_height = result['samples'][0]['global_joint_positions'][0][1]
metrics['root_bob_fraction_initial_hip_height'] = metrics['root_bob_model_units']['peak_to_peak']/hip_height
endpoint_error = max(abs(a-b) for a,b in zip(
    numbers(result['samples'][0]['global_matrices_row_major']),
    numbers(result['samples'][-1]['global_matrices_row_major'])))
source_paths = ['src/data/model/player_anim.c', 'src/data/model/boy_model.c',
                'src/c_keyframe.c', 'src/system/sys_matrix.c',
                'src/game/m_player_main_wait.c_inc', 'include/m_lib.h']
receipt = dict(animation='wait1', source_commit=PIN, source_animation_symbol='cKF_ba_r_ply_1_wait1',
    source_frames=33, source_phase_intervals=32, sample_count=129, full_endpoint_included=True,
    source_inputs=[dict(path=q, url='https://raw.githubusercontent.com/ACreTeam/ac-decomp/'+PIN+'/'+q,
                        sha256=digest(source_dir/Path(q).name), bytes=(source_dir/Path(q).name).stat().st_size)
                   for q in source_paths],
    extractor_sha256=digest(Path(__file__)), reference_curve_sha256=digest(curve_path),
    extractor_origin='Parsing, Hermite, and matrix helpers adapted from independent reviewer tools/ac_fk.py; extended with source binangle truncation and exhaustive existing WALK1 fixture comparison.',
    existing_walk_reference_sha256=digest(template_path), hierarchy_matches_existing_walk=True,
    regenerated_walk_sample_count=129, maximum_walk_numeric_error=maximum_error,
    loop_endpoint_global_matrix_maximum_error=endpoint_error, metrics=metrics,
    source_license='ac-decomp repository CC0; repository README excludes game assets. Public animation tables used as reference; no ROM, artwork, sound or full archive downloaded.',
    status='source reconstruction; not observed or bit-exact original GameCube runtime',
    limitations=result['approximation'], paid_calls=0, cost_usd=0,
    reproduction='python3 image-work/character-pilot/iterations/video-match/idle-reference-extract.py <directory-containing-pinned-source-files>')
(output_dir/'idle-reference-provenance.json').write_text(json.dumps(receipt, indent=2)+'\n')
print(json.dumps(dict(files=[str(curve_path), str(output_dir/'idle-reference-provenance.json')],
                      maximum_walk_numeric_error=maximum_error, endpoint_error=endpoint_error, metrics=metrics), indent=2))
