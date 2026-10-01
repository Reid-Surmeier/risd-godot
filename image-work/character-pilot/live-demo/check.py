"""Small integrity gate: exported shared rig, completed MCP stages and bound review evidence."""
from pathlib import Path
import hashlib,json,struct,subprocess
import numpy as np
HERE=Path(__file__).resolve().parent
PILOT=HERE.parent
read=lambda p:json.loads(p.read_text())
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def glb(path):
 raw=path.read_bytes();assert raw[:4]==b'glTF'
 size=struct.unpack_from('<I',raw,12)[0]
 return json.loads(raw[20:20+size]),raw[28+size:]
def view(doc,binary,index):
 v=doc['bufferViews'][index];start=v.get('byteOffset',0)
 return binary[start:start+v['byteLength']]
def accessor(doc,binary,index):return view(doc,binary,doc['accessors'][index]['bufferView'])
provenance=read(HERE/'evidence/provenance.json')
base,basebin=glb(PILOT/'iterations/video-match/fitted-walk/footplant-candidate.glb')
primitive=base['meshes'][0]['primitives'][0]
results={}
# Export can reorder/split vertices; compare the rigid head by its UV correspondence.
old,oldbin=glb(PILOT/'iterations/video-match/authored-walk-v5/footplant-candidate.glb')
def rigid_head(doc,binary):
 attrs=doc['meshes'][0]['primitives'][0]['attributes']
 def values(key,width):
  a=doc['accessors'][attrs[key]];v=doc['bufferViews'][a['bufferView']]
  dtype={5121:'u1',5123:'<u2',5126:'<f4'}[a['componentType']]
  return np.frombuffer(binary,dtype=dtype,count=a['count']*width,offset=v.get('byteOffset',0)+a.get('byteOffset',0)).reshape(a['count'],width)
 head=next(i for i,n in enumerate(doc['skins'][0]['joints']) if doc['nodes'][n]['name']=='Head')
 mask=np.sum((values('JOINTS_0',4)==head)*values('WEIGHTS_0',4),axis=1)>.9999
 return values('POSITION',3)[mask],values('TEXCOORD_0',2)[mask]
oldpositions,olduvs=rigid_head(old,oldbin)
positions,uvs=rigid_head(base,basebin)
for position,uv in zip(positions,uvs):
 matches=np.max(np.abs(olduvs-uv),axis=1)<1e-6
 assert matches.any() and np.min(np.linalg.norm(oldpositions[matches]-position,axis=1))<.00005
for name in ['walk','run','dash','skid','axe','net']:
 folder=PILOT/'iterations/video-match'/('fitted-'+name)
 asset=folder/'footplant-candidate.glb';receipt=read(folder/'correction.json');launch=read(folder/'mcp-launch.json')
 assert digest(asset)==receipt['output_sha256']==provenance['models'][name]['sha256']
 assert receipt['bones']==24 and receipt['rest_signature_unchanged'] and receipt['bake_fps']==240
 assert launch['transport']=='actual MCP stdio' and launch['successfully_scheduled']
 log=(folder/'mcp-native.log').read_text();assert receipt['output_sha256'] in log and 'Blender quit' in log and 'Traceback' not in log
 doc,binary=glb(asset);part=doc['meshes'][0]['primitives'][0]
 for key in ['POSITION','TEXCOORD_0','JOINTS_0','WEIGHTS_0']:
  assert accessor(base,basebin,primitive['attributes'][key])==accessor(doc,binary,part['attributes'][key]),(name,key)
 assert accessor(base,basebin,primitive['indices'])==accessor(doc,binary,part['indices'])
 assert view(base,basebin,base['images'][0]['bufferView'])==view(doc,binary,doc['images'][0]['bufferView'])
 assert accessor(base,basebin,base['skins'][0]['inverseBindMatrices'])==accessor(doc,binary,doc['skins'][0]['inverseBindMatrices'])
 assert base['skins'][0]['joints']==doc['skins'][0]['joints'] and base['nodes']==doc['nodes']
 if name in ['walk','run','dash']:
  contact=read(folder/'contact-manifest.json');assert contact['candidate_sha256']==digest(asset)
  for clip in ['idle','walk']:
   probe=contact['contact_probe'][clip]
   assert probe['sample_count']==257 and probe['floor_penetration_max_m']<.001 and probe['endpoint_vertex_error_max_m']<.001
 results[name]={'sha256':digest(asset),'shared_geometry_uv_texture_skin_rest':True}
originals=read(PILOT/'hashes.json')
for name in ['source.png','front.png','mesh-output-model_glb.glb','rig-output-rigged_character_glb.glb','rig-output-animations-0-animation_glb.glb','rig-output-basic_animations-walking_glb.glb','rig-output-basic_animations-running_glb.glb']:
 assert digest(PILOT/name)==originals[name],name
spend=read(PILOT/'spend.json');assert round(sum(e['liability_usd'] for e in spend['entries']),2)==1.54 and spend['ceiling_usd']==4
for name,sha in provenance['sources'].items():assert digest(HERE/name)==sha,name
for name,sha in provenance['evidence_hashes'].items():assert digest(HERE/'evidence'/name)==sha,name
browser=read(HERE/'evidence/browser.json');assert not browser['errors']
assert browser['keyboard']['partial_walk']['state']=='Walk' and browser['keyboard']['door_exit']['door_transitions']==2
assert browser['touch']['moving']['state']=='Dash'
assert browser['keyboard']['jump']['y']>.4 and browser['keyboard']['jump']['state']=='Jump'
assert browser['touch']['jump']['y']>.4 and browser['touch']['jump']['state']=='Jump'
native=read(HERE/'evidence/driven-check.json')
assert native['jump']['different_height_landing'] and native['jump']['elevated_contact']
assert native['jump']['midair_retrigger_blocked'] and native['jump']['airborne_steps']==0 and native['jump']['landings']==1
assert native['dust']['puffs_per_dry_contact']==1 and native['dust']['duration_updates']==18 and native['dust']['invisible_at_update']==16
assert native['dust']['source_motion_and_alpha'] and native['dust']['authored_masks']
trace=read(HERE/'evidence/record.json');assert trace['whole_viewport'] and len(trace['frames'])==240 and trace['fps']==30
assert {'Run','Dash','Skid','Idle'}<=set(f['state'] for f in trace['frames'])
for folder in [HERE/'evidence',HERE/'evidence/walk-alternative']:
 receipt=read(folder/'comparison.json')
 assert receipt['target_build_stamp']==provenance['stamp'] and receipt['target_scene_sha256']==digest(HERE/'demo.gd')
 assert receipt['target_models']=={name:value['sha256'] for name,value in provenance['models'].items()}
 assert not receipt['exact_match'] and not receipt['fixed_registration']['per_frame_warp']
 assert len(receipt['ground_tracks'])==61 and max(t['inlier_rms_px'] for t in receipt['ground_tracks'])<2
 for name,sha in receipt['artifact_hashes'].items():assert digest(folder/name)==sha
 probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=nb_frames,avg_frame_rate','-of','json',str(folder/'whole-view.mp4')]))['streams'][0]
 assert probe['nb_frames']=='60' and probe['avg_frame_rate']=='30/1'
stamp=hashlib.sha256((''.join(digest(p) for p in sorted(HERE.glob('*.gd')))+digest(HERE/'build.py')+digest(HERE/'appearance_check.py')+digest(HERE/'tool_clearance_check.py')+digest(HERE.parent/'iterations/video-match/hand-atlas-profile/hand-atlas.png')+''.join(value['sha256'] for value in provenance['models'].values())).encode()).hexdigest()[:12]
assert provenance['stamp']==stamp and provenance['additional_api_cost_usd']==0
appearance=read(HERE/'evidence/appearance-metrics.json')
assert appearance['mean_material_color_error_255']<1 and appearance['maximum_blink_level_jump']<.35
assert max(appearance['dust_visible_pixels'])>50 and sum(n>50 for n in appearance['dust_visible_pixels'])>=3
assert appearance['outside_face_changed_pixels']==0 and appearance['closed_eye_blue_bleed_pixels']==0
tool_geometry=read(HERE/'evidence/tool-clearance-check.json')
assert tool_geometry['head_test_poses']==632 and tool_geometry['regrip_poses']==1920 and tool_geometry['regrip_scenarios']==48 and tool_geometry['maximum_regrip_hand_step']<=.06 and not tool_geometry['regrip_failures'] and tool_geometry['inside_queries']==0 and tool_geometry['minimum_gap']>=.01 and not tool_geometry['failures']
hand_receipt=read(PILOT/'iterations/video-match/hand-atlas-profile/hand-atlas.json')
assert hand_receipt['uv_coordinates_unchanged'] and hand_receipt['output_sha256']==digest(PILOT/'iterations/video-match/hand-atlas-profile/hand-atlas.png')
contact_sweep=read(HERE/'evidence/contact-velocity-check.json')
assert contact_sweep['candidate_build']==provenance['stamp'] and contact_sweep['case_count']==200 and not contact_sweep['failures']
assert all(not r['cap_nocontact'] and not r['flight_back'] and not r['air_at_floor'] and r['impact']>.99 and r['last_three_air_pose_step']<=.06 for r in contact_sweep['runs'])
quality=read(HERE/'evidence/quality-check.json')
assert all(.40<v['ratio']<.65 for v in quality['quieter_idle'].values())
assert quality['contact_depth']['minimum_root_y']>=-.0025
assert all(v['descent_pose_monotonic'] and v['flat_hop_impact']>.8 and v['maximum_descent_land_hand_step']<=.07 for v in quality['mixed_input'].values())
assert set(quality['wrists'])=={'idle','walk','run','dash','skid','jump'}
assert quality['jump_transition']['updates']==100 and quality['jump_transition']['relative_wrist_error_degrees']<.1
assert set(quality['transitions'])=={'None','Axe','Net'}
assert all(p['relative_wrist_error_degrees']<.1 and p['settled_base_arm_error_degrees']<.1 and p['updates']==150 for p in quality['transitions'].values())
assert all(p['relative_wrist_error_degrees']<.1 and p['samples']==65 for p in quality['wrists'].values())
assert all(abs(p['reach_m']-.145)<.001 and p['thumb_projection_m']>.035 for p in quality['palms'].values())
assert quality['arm_clearance']['interior_vertices']==0 and quality['arm_clearance']['minimum_gap']>.005
assert len(quality['stop_clearance'])==15 and all(p['clearance']['interior_vertices']==0 for p in quality['stop_clearance'])
assert set(quality['tool_clearance'])=={'Axe','Net'} and all(p['interior_vertices']==0 for p in quality['tool_clearance'].values())
assert set(quality['mixed_input'])=={'press','apex','contact'}
assert all(v['maximum_landing_drop']<=.10 and v['maximum_head_hips_step']<=.06 for v in quality['mixed_input'].values())
assert quality['sprint_jump']['maximum_lean_step_degrees']<=3.001 and quality['sprint_jump']['maximum_head_step']<=.059
assert set(quality['moving_jump'])=={'None','Axe','Net'}
assert all(p['updates']==100 and p['maximum_horizontal_speed_change']<=.6 and p['launch_tick']<=2 and p['first_update_palm_displacement']<.10 and p['recovered_gait']=='Run' for p in quality['moving_jump'].values())
pose=read(HERE/'evidence/jump-pose-check.json')
assert .02<pose['grounded_compression']<.06 and .04<pose['landing_compression']<.12 and pose['arm_drive']>.20
assert pose['maximum_bone_step']<=.06 and pose['planted_horizontal_drift']<=.01 and pose['maximum_planted_root_correction']<=.005
assert [cue['bank'] for cue in pose['jump_audio']]==['Jump','Landing']
assert [cue['stage'] for cue in pose['jump_audio']]==['Ascend','Land']
assert pose['stages']==['Anticipate','Ascend','Descend','Land','Ground']
assert pose['trace'][pose['contact_tick']]['floor'] and pose['trace'][pose['contact_tick']]['phase']=='Land'
assert quality['idle_silent'] and not quality['exact_original_waveforms']
print('PASS: six completed MCP clips, shared exported rig/appearance, dense native receipts, browser/whole-view evidence and $1.54 original liability')
