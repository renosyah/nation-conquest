extends Spatial
class_name BaseProjectile

signal hit

export var speed :int = 12
export var target :Vector3
export var margin :int = 1
export var curve :bool = true
export var accuration :float = 1.0

onready var _initial_distance :float = translation.distance_squared_to(target)
var _target :Vector3
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
	_target = Vector3(target.x, target.y + (10 if curve else 0), target.z)
	look_at(_target, Vector3.UP)
	visible = true
	set_process(true)
	
func _add_offset():
	var offset = (1 - accuration)
	var rand_offset = rand_range(-offset, offset)
	target = target + (Vector3(1, 0, 1) * rand_offset)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance :float = translation.distance_squared_to(target)
	if distance <= margin:
		emit_signal("hit")
		set_process(false)
		_arrow_stick.start()
		return
		
	var direction :Vector3 = translation.direction_to(target)
	if curve:
		var is_half_distance :bool = _initial_distance / 2 < distance
		direction.y += 0.5 if is_half_distance else -0.5
		_target.y = lerp(_target.y, target.y, (speed / 2) * delta)
		look_at(_target, Vector3.UP)
	
	translation += direction * speed * delta
	
func _arrow_stick_timeout():
	visible = false
