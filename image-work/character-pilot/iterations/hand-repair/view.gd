extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(960,720)
 var demo=load("res://demo.gd").new();root.add_child(demo);demo.set_physics_process(false)
 await process_frame
 for layer in demo.find_children("*","CanvasLayer",true,false):layer.visible=false
 demo.skeleton.reset_bone_poses();demo.skeleton.force_update_all_bone_transforms()
 var hand=demo.skeleton.global_transform*demo.skeleton.get_bone_global_rest(demo.skeleton.find_bone("LeftHand"))
 print("HAND_WORLD",hand)
 demo.camera.projection=Camera3D.PROJECTION_ORTHOGONAL;demo.camera.size=.45
 demo.camera.position=hand.origin+Vector3(.07,0,3);demo.camera.look_at(hand.origin+Vector3(.07,0,0))
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://hand-rest-front.png")
 demo.camera.position=hand.origin+Vector3(.07,3,0);demo.camera.look_at(hand.origin+Vector3(.07,0,0),Vector3.FORWARD)
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://hand-rest-top.png")
 quit()
