extends BaseUi

onready var mini_map = $CanvasLayer/SafeArea/Control/MarginContainer2/MiniMap
onready var camera_control = $CanvasLayer/SafeArea/Control/MarginContainer2/camera_control

func _ready():
	pass
	
func get_camera_moving_direction() -> Vector2:
	return camera_control.get_moving_direction()
	
func get_camera_zoom() -> float:
	return camera_control.get_zoom()
	
func add_minimap_object(object_path :NodePath, color :Color = Color.white):
	mini_map.add_object(object_path, color)
