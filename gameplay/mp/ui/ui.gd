extends BaseUi

onready var control = $CanvasLayer/Control
onready var mini_map = $CanvasLayer/Control/MarginContainer2/MiniMap

onready var camera_control = $CanvasLayer/Control/MarginContainer2/camera_control
onready var fps_ping_displayer = $CanvasLayer/Control/MarginContainer2/fps_ping_displayer

func _ready():
	control.visible = true
	
func get_camera_moving_direction() -> Vector2:
	return camera_control.get_moving_direction()
	
func get_camera_zoom() -> float:
	return camera_control.get_zoom()
	
