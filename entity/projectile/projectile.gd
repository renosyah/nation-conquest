extends Spatial
class_name BaseProjectile

signal hit

export var speed :int = 12
export var target :Vector3
export var margin :int = 1
export var curve :bool = true

onready var _initial_distance :float = translation.distance_squared_to(target)
var _target :Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	visible = false
	set_process(false)
	
func fire():
	_target = Vector3(target.x, target.y + (10 if curve else 0), target.z)
	look_at(_target, Vector3.UP)
	visible = true
	set_process(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance :float = translation.distance_squared_to(target)
	if distance <= margin:
		emit_signal("hit")
		set_process(false)
		visible = false
		return
		
	var direction :Vector3 = translation.direction_to(target)
	if curve:
		var is_half_distance :bool = _initial_distance / 2 < distance
		direction.y += 0.5 if is_half_distance else -0.5
		_target.y = lerp(_target.y, target.y, (speed / 2) * delta)
		look_at(_target, Vector3.UP)
	
	translation += direction * speed * delta
