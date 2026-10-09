extends SceneTree
const V=preload("res://virgin_child_asset.gd")
var failures:=[]
func _initialize():call_deferred("run")
func run():
	var geometry=V.parts()
	var top:=-INF
	var triangles:=0
	var count:=0
	for group in geometry.values():
		for shell in group:
			count+=1
			var edges:={}
			for i in range(0,shell.size(),3):
				triangles+=1
				if (shell[i+1]-shell[i]).cross(shell[i+2]-shell[i]).length()<1e-10:failures.append("degenerate triangle")
				for j in 3:
					var a=str(shell[i+j].snapped(Vector3.ONE*.000001))
					var b=str(shell[i+(j+1)%3].snapped(Vector3.ONE*.000001))
					var key=a+"/"+b if a<b else b+"/"+a
					edges[key]=edges.get(key,0)+1
			for edge in edges:
				if edges[edge]!=2:failures.append("unclosed or duplicate surface edge")
			for point in shell:top=max(top,point.y)
	if abs(top-.394)>.000001:failures.append("catalogue height mismatch")
	var world=Node3D.new();root.add_child(world)
	var figure=V.build();world.add_child(figure)
	var environment=WorldEnvironment.new();var e=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color("dbd7cd");e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color.WHITE;e.ambient_light_energy=.75;environment.environment=e;world.add_child(environment)
	var light=DirectionalLight3D.new();light.rotation_degrees=Vector3(-35,-35,0);light.light_energy=.65;world.add_child(light)
	var camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=.47;world.add_child(camera);camera.current=true
	for view in [["front",Vector3(0,.197,.8)],["right",Vector3(-.8,.197,0)],["left",Vector3(.8,.197,0)],["rear",Vector3(0,.197,-.8)],["oblique",Vector3(-.65,.37,.65)]]:
		camera.position=view[1];camera.look_at(Vector3(0,.197,0));await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://"+view[0]+".png")
	var result={"closed_parts":count,"triangles":triangles,"height_m":top,"failures":failures,"rear_accepted":false,"placement_accepted":false}
	var file=FileAccess.open("res://checks.json",FileAccess.WRITE);file.store_string(JSON.stringify(result,"  "));file.close();print("VIRGIN_CHECK ",JSON.stringify(result));quit(0 if failures.is_empty() else 1)
