extends Spatial
class_name RtsCamera

var _is_moving :bool = false
var _interpolate_to :Vector3

onready var camera = $Camera

func set_moving_direction(dir :Vector2):
	translation -= Vector3(dir.x, 0.0, dir.y)
	
func set_zoom(zoom_level :float):
	camera.translation.z = zoom_level
	
func move_to(to :Vector3):
	_is_moving = true
	_interpolate_to = to
	
func _process(delta):
	if not _is_moving:
		return
	
	if translation.distance_squared_to(_interpolate_to) < 1.0:
		_is_moving = false
		return
		 
	translation = translation.linear_interpolate(_interpolate_to, 5 * delta)
