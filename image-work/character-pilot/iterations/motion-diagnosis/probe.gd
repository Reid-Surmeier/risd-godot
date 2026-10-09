extends SceneTree
var skeleton: Skeleton3D
var player: AnimationPlayer
var vertices: Array = []
func _initialize():
 call_deferred("run")
func vec(v: Vector3):
 return [v.x,v.y,v.z]
func points(sole_only: bool = false):
 var out: Array[Vector3] = []
 for item in vertices:
  if sole_only and item.side=="":
   out.append(Vector3.ZERO)
   continue
  var p := Vector3.ZERO
  for inf in item.influences:
   p += (skeleton.get_bone_global_pose(inf.bone)*inf.bind*item.vertex)*inf.weight
  out.append(skeleton.global_transform*p)
 return out
func pose(t: float):
 player.seek(t,true)
 skeleton.force_update_all_bone_transforms()
 var transforms: Array[Transform3D] = []
 for b in skeleton.get_bone_count():
  transforms.append(skeleton.global_transform*skeleton.get_bone_global_pose(b))
 return transforms
func run():
 var model = load("res://target.glb").instantiate()
 root.add_child(model)
 await process_frame
 skeleton=model.find_children("*","Skeleton3D",true,false)[0]
 player=model.find_children("*","AnimationPlayer",true,false)[0]
 player.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
 for mesh in model.find_children("*","MeshInstance3D",true,false):
  for surface in mesh.mesh.get_surface_count():
   var arrays=mesh.mesh.surface_get_arrays(surface)
   for index in arrays[Mesh.ARRAY_VERTEX].size():
    var item={"vertex":arrays[Mesh.ARRAY_VERTEX][index],"influences":[],"side":""}
    var weights={"Left":0.0,"Right":0.0}
    for i in 4:
     var weight: float=arrays[Mesh.ARRAY_WEIGHTS][index*4+i]
     if weight==0: continue
     var bind: int=arrays[Mesh.ARRAY_BONES][index*4+i]
     var bone: int=mesh.skin.get_bind_bone(bind)
     if bone<0: bone=skeleton.find_bone(mesh.skin.get_bind_name(bind))
     item.influences.append({"bone":bone,"bind":mesh.skin.get_bind_pose(bind),"weight":weight})
     var name=skeleton.get_bone_name(bone)
     for side in weights:
      if name==side+"Foot" or name==side+"ToeBase": weights[side]+=weight
    for side in weights:
     if weights[side]>.5: item.side=side
    vertices.append(item)
 var restpoints=points()
 var rest= {}
 for name in ["Head","headfront","LeftUpLeg","LeftLeg","LeftFoot","LeftToeBase"]:
  var b=skeleton.find_bone(name)
  var tr=skeleton.global_transform*skeleton.get_bone_global_rest(b)
  rest[name]={"position":vec(tr.origin),"basis_x":vec(tr.basis.x.normalized()),"basis_y":vec(tr.basis.y.normalized()),"basis_z":vec(tr.basis.z.normalized())}
 var head=skeleton.get_bone_global_rest(skeleton.find_bone("Head"))
 var front=skeleton.get_bone_global_rest(skeleton.find_bone("headfront"))
 var forward=head.basis.inverse()*(front.origin-head.origin).normalized()
 var animation: Animation=player.get_animation("walk").duplicate(true)
 var imported_loop=animation.loop_mode
 animation.loop_mode=Animation.LOOP_NONE
 var library=AnimationLibrary.new()
 library.add_animation("walk",animation)
 player.add_animation_library("probe",library)
 player.play("probe/walk")
 var length=animation.length
 var start=pose(0.0)
 var startpoints=points()
 var finish=pose(length)
 var finishpoints=points()
 var seam=[]
 var maxp=0.0
 var maxangle=0.0
 for b in skeleton.get_bone_count():
  var p=start[b].origin.distance_to(finish[b].origin)
  var angle=rad_to_deg(start[b].basis.orthonormalized().get_rotation_quaternion().angle_to(finish[b].basis.orthonormalized().get_rotation_quaternion()))
  maxp=max(maxp,p);maxangle=max(maxangle,angle)
  seam.append({"bone":skeleton.get_bone_name(b),"position_m":p,"rotation_deg":angle})
 var maxvertex=0.0
 var rms=0.0
 for i in startpoints.size():
  var d=startpoints[i].distance_to(finishpoints[i])
  maxvertex=max(maxvertex,d);rms+=d*d
 rms=sqrt(rms/startpoints.size())
 var samples=[]
 for i in 257:
  var t=length*i/256.0
  var transforms=pose(t)
  var pts=points(true)
  var sample={"time":t,"hips":vec(transforms[skeleton.find_bone("Hips")].origin),"feet":{}}
  for side in ["Left","Right"]:
   var low=Vector3.INF;var high=-Vector3.INF
   var centroid=Vector3.ZERO;var count=0
   for v in vertices.size():
    if vertices[v].side==side:
     low=low.min(pts[v]);high=high.max(pts[v]);centroid+=pts[v];count+=1
   sample.feet[side]={"min":vec(low),"max":vec(high),"centroid":vec(centroid/count),"weighted_vertices":count,"ankle":vec(transforms[skeleton.find_bone(side+"Foot")].origin)}
  samples.append(sample)
 var epsilon=length/32.0
 var nearstart=pose(epsilon)
 var nearend=pose(length-epsilon)
 var speeds=[]
 for b in skeleton.get_bone_count():
  var va=(nearstart[b].origin-start[b].origin)/epsilon
  var vb=(finish[b].origin-nearend[b].origin)/epsilon
  speeds.append({"bone":skeleton.get_bone_name(b),"start_velocity_mps":vec(va),"end_velocity_mps":vec(vb),"velocity_jump_mps":va.distance_to(vb)})
 var convergence=[]
 for delta in [0.01,0.003,0.001,0.0003]:
  var a=pose(delta)
  var b=pose(length-delta)
  var maximum=0.0
  var worst=""
  for joint in skeleton.get_bone_count():
   var va=(a[joint].origin-start[joint].origin)/delta
   var vb=(finish[joint].origin-b[joint].origin)/delta
   var jump=va.distance_to(vb)
   if jump>maximum:maximum=jump;worst=skeleton.get_bone_name(joint)
  convergence.append({"delta_seconds":delta,"maximum_joint_velocity_jump_mps":maximum,"worst_bone":worst})
 var contacts=[]
 for side in ["Left","Right"]:
  var t=length*(0.25 if side=="Left" else 0.75)
  var delta=0.001
  var before=pose(t-delta)
  var at=pose(t)
  var after=pose(t+delta)
  var joint=skeleton.find_bone(side+"Foot")
  var incoming=(at[joint].origin-before[joint].origin)/delta+Vector3(0,0,.52)
  var outgoing=(after[joint].origin-at[joint].origin)/delta+Vector3(0,0,.52)
  contacts.append({"foot":side,"time":t,"incoming_world_velocity_mps":vec(incoming),"outgoing_world_velocity_mps":vec(outgoing),"jump_mps":incoming.distance_to(outgoing)})
 var tracks=[]
 for i in animation.get_track_count():
  var n=animation.track_get_key_count(i)
  tracks.append({"path":str(animation.track_get_path(i)),"type":animation.track_get_type(i),"keys":n,"first_time":animation.track_get_key_time(i,0),"last_time":animation.track_get_key_time(i,n-1),"interpolation":animation.track_get_interpolation_type(i),"loop_wrap":animation.track_get_interpolation_loop_wrap(i)})
 var evidence={"godot":Engine.get_version_info().string,"bones":skeleton.get_bone_count(),"seconds":length,"imported_loop_mode":imported_loop,"endpoint_loop_mode":animation.loop_mode,"rest":rest,"head_to_headfront_local_direction":vec(forward),"seam":{"maximum_bone_position_m":maxp,"maximum_bone_rotation_deg":maxangle,"maximum_vertex_displacement_m":maxvertex,"rms_vertex_displacement_m":rms,"bones":seam,"one_sided_velocities":speeds},"samples":samples,"velocity_convergence":convergence,"contact_boundary_velocities":contacts,"tracks":tracks,"sole_definition":"vertices with >50% total Foot+ToeBase weight; minimum of their skinned bounds, not a ground/contact sensor"}
 FileAccess.open("res://evidence.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"  ")+"\n")
 print("MOTION_DIAGNOSIS ",length," seconds; seam maxvertex ",maxvertex,"; maxangle ",maxangle)
 quit()
