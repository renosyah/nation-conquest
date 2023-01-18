extends Node

onready var ui = $ui
onready var rts_camera = $rts_camera
onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	rts_camera.translation.y += 35
	
	tween.interpolate_property(rts_camera, "translation:y", 35, 7, 2.2, Tween.TRANS_SINE)
	tween.start()
	
func _on_Tween_tween_all_completed():
	ui.show_ui()
