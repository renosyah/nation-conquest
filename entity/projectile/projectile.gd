extends Spatial
class_name BaseProjectile

signal hit

export var speed :int = 12
export var target :Vector3
export var margin :int = 1
export var curve :bool = true
export var accuration :float = 1.0

var _trajectory_direction :Vector3
var _trajectory_aim :Vector3
var _arrow_stick :Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	_arrow_stick = Timer.new()
	_arrow_stick.wait_time = 1
	_arrow_stick.one_shot = true
	_arrow_stick.connect("timeout", self ,"_arrow_stick_timeout")
	add_child(_arrow_stick)
	
	set_as_toplevel(true)
	visible = false
	set_process(false)
	
func fire():
	_add_offset()
	var _initial_distance :float = translation.distance_to(target)
	_trajectory_aim = Vector3(
		target.x, target.y + (_initial_distance if curve else 0), target.z
	)
	_trajectory_direction = _trajectory_aim.direction_to(target)
	look_at(_trajectory_aim, Vector3.UP)
	visible = true
	set_process(true)
	
func _add_offset():
	var offset = (1 - accuration)
	var rand_offset = rand_range(-offset, offset) + 0.5
	target = target + (Vector3(1, 0, 1) * rand_offset)
	target.y -= -0.1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance :float = translation.distance_squared_to(target)
	if distance <= margin:
		emit_signal("hit")
		set_process(false)
		_arrow_stick.start()
		return
		
	var arrow_direction :Vector3 = translation.direction_to(_trajectory_aim)
	translation += arrow_direction * speed * delta
	look_at(arrow_direction * 100, Vector3.UP)
	
	if curve:
		_trajectory_aim += _trajectory_direction * speed * delta
	
func _arrow_stick_timeout():
	visible = false
