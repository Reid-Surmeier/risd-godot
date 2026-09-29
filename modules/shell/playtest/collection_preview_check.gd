## #189: actual painting click, presentation swap, return, and closer camera.
extends "res://testing/harness_base.gd"
var failures := 0
var stage: Control
func require(ok: bool, message: String) -> void:
 if not ok:
  failures += 1
  print("FAIL ", message)
func _initialize() -> void:
 call_deferred("run")
func screen(point: Vector2) -> Vector2:
 return stage.stage_rect.position + point / 1080.0 * stage.stage_rect.size
func run() -> void:
 stage = load("res://modules/shell/demo.tscn").instantiate()
 var out := await _mount(stage, Vector2i(1080,1080), "/tmp/collection-preview-189")
 stage.enabled = false
 stage._publish_state()
 await create_timer(1.0).timeout
 var picture: TextureRect = stage.find_child("CollectionFrame",true,false)
 var walk: Control = picture.get_node("GalleryWalk")
 walk._new_action()
 walk._entrance_waiting = false
 walk._entrance_active = false
 walk._target = null
 walk._path.clear()
 walk._pos = Vector3(2,0,-4)
 walk.view_yaw = PI
 walk._update_camera(1.0)
 await _frames(4)
 var foot: Vector2 = walk._cam.unproject_position(walk._pos) / Vector2(walk._vp.size)
 var head: Vector2 = walk._cam.unproject_position(walk._pos + Vector3.UP * walk.KID_H) / Vector2(walk._vp.size)
 print("CAMERA_COMPOSITION height=",foot.y-head.y," feet=",foot.y)
 require(foot.y-head.y > 0.26 and foot.y-head.y < 0.36, "character is not closer")
 require(foot.y > 0.75 and foot.y < 0.86, "character feet leave intended composition")
 await _shot(out,"gameplay.png")
 var initial_rect: Rect2 = walk.get_rect()
 var painting: Dictionary = walk._paintings[0]
 walk._pos = painting.center + painting.normal * 2.6
 walk._pos.y = 0
 walk.view_yaw = atan2(painting.normal.x,painting.normal.z)
 walk._update_camera(1.0)
 await _frames(6)
 var outline: PackedVector2Array = walk._visible_outline(painting.corners)
 var point := Vector2.ZERO
 for vertex in outline: point += vertex / outline.size()
 await _click(screen(walk.global_position + point),"painting")
 for i in 120:
  if not walk._open.is_empty(): break
  await create_timer(0.1).timeout
 require(walk._open.get("tag", "") == painting.tag,"painting click did not open detail")
 await create_timer(0.5).timeout
 require(picture.self_modulate.a == 0,"outer Collection frame remains around artwork")
 require(walk.size.y > picture.size.y * 0.9,"artwork did not expand to its own window")
 var pic: TextureRect = walk._zoom_root.get_node("Painting")
 require(absf(pic.size.aspect()-pic.texture.get_size().aspect())<0.001,"artwork aspect changed")
 await _shot(out,"preview.png")
 var position_before: Vector3 = walk._pos
 var camera_before: Transform3D = walk._cam.global_transform
 var close: Control = walk._detail.get_node("Close")
 await _click(screen(close.get_global_rect().get_center()),"close preview")
 await create_timer(0.5).timeout
 require(walk._open.is_empty() and not walk._detail.visible,"X did not close preview")
 require(picture.self_modulate.a == 1 and walk.get_rect().is_equal_approx(initial_rect),"original frame/opening was not restored")
 require(walk._pos.distance_to(position_before)<0.001 and walk._cam.global_transform.is_equal_approx(camera_before),"return moved visitor/camera")
 require(stage.find_child("Fullscreen",true,false)!=null,"fullscreen control missing")
 await _shot(out,"returned.png")
 print("COLLECTION_PREVIEW_FAILURES ",failures)
 quit(1 if failures else 0)
