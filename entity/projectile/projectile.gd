extends Spatial
class_name BaseProjectile

signal hit

export var speed :int = 12
export var target :Vector3
export var margin :int = 1
export var curve :bool = true
export var accuration :float = 1.0
export var is_static :bool = false

var _trajectory_aim :Vector3
var _arrow_stick :Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	_arrow_stick = Timer.new()
	_arrow_stick.wait_time = 1
	_arrow_stick.one_shot = true
	_arrow_stick.autostart = false
	_arrow_stick.connect("timeout", self ,"_arrow_stick_timeout")
	add_child(_arrow_stick)
	
	set_as_toplevel(true)
	visible = false
	set_process(false)
	
func fire():
	var offset = (1 - accuration)
	var rand_offset = rand_range(-offset, offset) + 0.5
	target = target + (Vector3(1, 0, 1) * rand_offset)
	
	_trajectory_aim = target
	if curve:
		_trajectory_aim.y = target.y + translation.distance_to(target)
	
	look_at(_trajectory_aim, Vector3.UP)
	visible = true
	set_process(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance :float = translation.distance_to(_trajectory_aim)
	if distance <= margin:
		_on_hit()
		return
		
	var arrow_direction :Vector3 = translation.direction_to(_trajectory_aim)
	translation += arrow_direction * speed * delta
	
	if not is_static:
		look_at(_trajectory_aim, Vector3.UP)
	
	if curve and _trajectory_aim.y > target.y:
		_trajectory_aim += Vector3.DOWN * speed * delta
	
func _on_hit():
	emit_signal("hit")
	set_process(false)
	_arrow_stick.start()
	
func _arrow_stick_timeout():
	visible = false
