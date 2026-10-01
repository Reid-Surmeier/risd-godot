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
trace=read(HERE/'evidence/record.json');assert trace['whole_viewport'] and len(trace['frames'])==240 and trace['fps']==30
assert {'Run','Dash','Skid','Idle'}<=set(f['state'] for f in trace['frames'])
for folder in [HERE/'evidence',HERE/'evidence/walk-alternative']:
 receipt=read(folder/'comparison.json')
 assert not receipt['exact_match'] and not receipt['fixed_registration']['per_frame_warp']
 assert len(receipt['ground_tracks'])==61 and max(t['inlier_rms_px'] for t in receipt['ground_tracks'])<2
 for name,sha in receipt['artifact_hashes'].items():assert digest(folder/name)==sha
 probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=nb_frames,avg_frame_rate','-of','json',str(folder/'whole-view.mp4')]))['streams'][0]
 assert probe['nb_frames']=='60' and probe['avg_frame_rate']=='30/1'
assert provenance['stamp']=='ef23e8a84775' and provenance['additional_api_cost_usd']==0
print('PASS: six completed MCP clips, shared exported rig/appearance, dense native receipts, browser/whole-view evidence and $1.54 original liability')
