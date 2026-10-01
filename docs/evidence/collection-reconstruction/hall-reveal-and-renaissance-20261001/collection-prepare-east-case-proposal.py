from pathlib import Path
import json,hashlib
r=Path('/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction');mods=r/'modules/shell/prototype/collection_reconstruction';out=r/'docs/evidence/collection-reconstruction/hall-reveal-and-renaissance-20261001/east-case-proposal';out.mkdir(exist_ok=False)
base={};sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=mods/'remodel_room.gd';s=p.read_text();base[str(p.relative_to(r))]=sha(p)
s=s.replace('const Pieta := preload("res://pieta_asset.gd")','const Pieta := preload("res://pieta_asset.gd")\nconst RenaissanceA := preload("res://renaissance_case_a_assets.gd")\nconst RenaissanceB := preload("res://renaissance_case_b_assets.gd")')
s=s.replace('var _renaissance_pieta_case:StaticBody3D','var _renaissance_pieta_case:StaticBody3D\nvar _renaissance_east_cases:Array[StaticBody3D]=[]')
needle='\tassert(_renaissance_triptych_case.get_parent().get_meta("room_wall", "") == "light Renaissance room:north")';assert s.count(needle)==1
s=s.replace(needle,needle+'''
	for display in _renaissance_east_cases:
		for wall in casings:
			if wall.get_meta("room_wall", "") == "light Renaissance room:east" and abs(wall.position.z-display.position.z)<.1:
				display.reparent(wall)
				break
		assert(display.get_parent().get_meta("room_wall", "") == "light Renaissance room:east")''')
needle='\t# Original6383 24.6/30.2s: dark narrow top rails and corner seams, not a floor plinth.';assert needle in s;s=s.replace(needle,'\tbuild_renaissance_east_cases()\n'+needle)
s+='\n'+Path('/tmp/collection-renaissance-east-cases.gd').read_text();(out/p.name).write_text(s)
p=mods/'prepare_remodel.py';s=p.read_text();base[str(p.relative_to(r))]=sha(p)
needle="copy(app/'triptych-2021131-geometry.json','assets/triptych-2021131-geometry.json')";assert needle in s;s=s.replace(needle,needle+'''
for case in ['a','b']:
    for original in sorted((app/f'renaissance-case-{case}').rglob('*')):
        if original.is_file():
            copy(original,Path('assets')/f'renaissance-case-{case}'/original.relative_to(app/f'renaissance-case-{case}'))
copy(app/'trial/cleric-45042-frame-fitted.png','assets/cleric-45042-frame-fitted.png')
copy(app/'renaissance-east-case-installation.json','assets/renaissance-east-case-installation.json')''')
old="'triptych_asset.gd','pieta_asset.gd']";assert old in s;s=s.replace(old,"'triptych_asset.gd','pieta_asset.gd','renaissance_case_a_assets.gd','renaissance_case_b_assets.gd']")
needle='    copy(source/name,name)';assert s.count(needle)==1;s=s.replace(needle,needle+'''
    if name=='renaissance_case_b_assets.gd':
        target=out/name
        target.write_text(target.read_text().replace('preload("../gallery_walk4/painting_asset.gd")','preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")'))''');(out/p.name).write_text(s)
p=mods/'architecture_check.gd';s=p.read_text();base[str(p.relative_to(r))]=sha(p)
s=s.replace('\tvar case_rails := 0','\tvar case_rails := 0\n\tvar east_cases := 0\n\tvar east_objects := {}')
needle='\t\tif node.has_meta("wall_case_top_rail"):';assert needle in s;s=s.replace(needle,'''		if node.has_meta("renaissance_wall_case"):
			east_cases += 1
			if node.get_parent().get_meta("room_wall", "") != "light Renaissance room:east" or not node is StaticBody3D:
				failures.append("East case lost its wall cutaway owner or collision")
		if node.has_meta("renaissance_case_object"):
			var key:String=node.get_meta("renaissance_case_object")
			east_objects[key]=east_objects.get(key,0)+1
			var owner:Node=node.get_parent()
			while owner!=null and not owner.has_meta("renaissance_wall_case"):owner=owner.get_parent()
			if owner==null:failures.append("Renaissance object lost case owner: "+key)
			for flag in ["placement_accepted","fine_fidelity_accepted","metric_accepted","whole_room_complete"]:
				if node.get_meta(flag,false):failures.append("Renaissance object prematurely accepted: "+key)
'''+needle)
needle='\tif case_rails!=8:';assert needle in s;s=s.replace(needle,'''	if east_cases!=2:failures.append("Expected two Renaissance east-wall cases")
	if east_objects.size()!=11 or not east_objects.values().all(func(n):return n==1):failures.append("Expected each of eleven Renaissance case objects once")
'''+needle)
s=s.replace('"case_rails":case_rails,','"case_rails":case_rails,"east_cases":east_cases,"east_objects":east_objects,');(out/p.name).write_text(s)
p=r/'image-work/collection-room-remodel/sculpture-room-inventory.json';j=json.loads(p.read_text());base[str(p.relative_to(r))]=sha(p)
for item in j['rooms']['renaissance']['wall_groups']:
 if item['id'] in ['books-portraits-case','majolica-medals-case']:
  item['status']='Closed source-guided low polygon asset studies installed in a provisional wall-hung case; positions, depths, frames and fine fidelity unaccepted.'
  item['prototype_objects']=6 if item['id']=='books-portraits-case' else 5
  item['placement_accepted']=False;item['case_metres_accepted']=False;item['fine_fidelity_accepted']=False
  if 'emblem_book' in item:item['emblem_book']['asset_built']=True
(out/p.name).write_text(json.dumps(j,indent=2)+'\n');(out/'base-sha256.json').write_text(json.dumps(base,indent=2)+'\n');print('East cases proposed in separate proof folder; four frozen live sources unchanged')
