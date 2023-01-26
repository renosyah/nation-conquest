extends Spatial
class_name RtsCamera

var default_rotation_degrees :float = -45

onready var camera = $Camera

func on_orientation_change(screen_orientation :int):
	match (screen_orientation):
		#OS.SCREEN_ORIENTATION_LANDSCAPE:
		0:
			rotation_degrees.x = -45
			default_rotation_degrees = -45
			camera.keep_aspect = Camera.KEEP_HEIGHT
			
		#OS.SCREEN_ORIENTATION_PORTRAIT:
		1:
			rotation_degrees.x = -55
			default_rotation_degrees = -55
			camera.keep_aspect = Camera.KEEP_WIDTH

func set_moving_direction(dir :Vector2):
	translation -= Vector3(dir.x, 0.0, dir.y)
	
func set_zoom(zoom_level :float):
	camera.translation.z = zoom_level
	
func _process(delta):
	if camera.translation.z < 12:
		rotation_degrees.x = lerp(
			rotation_degrees.x, -25, 5 * delta
		)
	else:
		rotation_degrees.x = lerp(
			rotation_degrees.x, default_rotation_degrees, 5 * delta
		)
		
# will returning position of camera looking at
# instead of using value facing direction
# this can be use for more accurate aiming
func get_camera_aiming_at(_crosshair :Vector2, exclude_body :Array = []) -> CameraAimingData:
	var aiming_data :CameraAimingData = CameraAimingData.new()
	
	var ray_from :Vector3 = camera.project_ray_origin(_crosshair)
	var ray_dir :Vector3 = camera.project_ray_normal(_crosshair)
	var ray_cast_to :Vector3 = ray_from + ray_dir * 1000
	aiming_data.position = ray_cast_to
		
	var col :Dictionary = get_world().direct_space_state.intersect_ray(
		ray_from, ray_cast_to, exclude_body, 0b11
	)
	if not col.empty():
		aiming_data.from_dictionary(col)
		
	aiming_data.distance = ray_from.distance_to(
		aiming_data.position
	)
	return aiming_data
	
