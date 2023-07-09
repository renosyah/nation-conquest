extends CanvasLayer

onready var animation_player = $AnimationPlayer

func change_scene(scene :String):
	animation_player.play("show")
	yield(animation_player,"animation_finished")
	
	get_tree().change_scene(scene)
	yield(get_tree(),"idle_frame")
	
	animation_player.play_backwards("show")
