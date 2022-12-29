extends Spatial
class_name Tap

onready var animation_player = $AnimationPlayer

func tap():
	animation_player.play("tap")
