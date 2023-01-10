extends Spatial
class_name AutoBuilder

signal placement_found(_building ,_pos)

export var height :float = 20.0
export var radius :float = 15.0
export var duration :float = 2.0

onready var rotation_pivot = $rotation_pivot
onready var h_pivot = $rotation_pivot/h_pivot
onready var timer = $Timer

onready var _radius :Vector3 = Vector3(radius, 0, 0)
var building :BaseBuilding
var placement_pos :Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func find_placement():
	if not is_instance_valid(building):
		return
		
	_radius = Vector3(radius, 0, 0)
	rotation_pivot.translation.y = height
	
	timer.wait_time = duration
	timer.start()
	
	set_process(true)

func _start_building():
	if not is_instance_valid(building):
		return
		
	h_pivot.translation.x = 0
	emit_signal("placement_found", building, placement_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_pivot.rotate_y(deg2rad(90) * delta)
	
	h_pivot.translation = h_pivot.translation.linear_interpolate(
		_radius, 5 * delta
	)
	
	placement_pos = _get_cast_position().position
	building.translation = placement_pos
	
	if timer.is_stopped() and building.can_build:
		set_process(false)
		_start_building()
		return
		
func _get_cast_position() -> CameraAimingData:
	var aiming_data :CameraAimingData = CameraAimingData.new()
	var ray_cast_to :Vector3 = h_pivot.global_transform.origin + Vector3.DOWN * 1000
	aiming_data.position = ray_cast_to
	
	var col :Dictionary = get_world().direct_space_state.intersect_ray(
		h_pivot.global_transform.origin, ray_cast_to, [], 0b11
	)
	if not col.empty():
		aiming_data.from_dictionary(col)
		
	aiming_data.distance = h_pivot.global_transform.origin.distance_to(
		aiming_data.position
	)
	
	return aiming_data










