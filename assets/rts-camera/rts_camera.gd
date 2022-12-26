extends Spatial
class_name RtsCamera

onready var camera = $Camera

func set_moving_direction(dir :Vector2):
	translation -= Vector3(dir.x, 0.0, dir.y)
	
func set_zoom(zoom_level :float):
	camera.translation.z = zoom_level
	
