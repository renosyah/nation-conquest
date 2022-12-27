extends KinematicBody
class_name BaseUnit

signal unit_selected(_unit)
signal unit_take_damage(_unit, _damage)
signal unit_dead(_unit)

export var is_dead :bool = false
export var team :int = 0
export var color :Color = Color.white
export var hp :int = 5
export var max_hp :int = 5

export var is_moving :bool = false
export var move_to :Vector3
export var margin :float = 0.3
export var speed :int = 2

var _direction :Vector3
var _velocity :Vector3

export var is_attacking :bool = false
var attack_to = null
export var attack_damage :int = 1
export var attack_delay :float = 0.4
export var attack_range :float = 1

var _attack_delay_timmer :Timer
var _input_detection :Node

# Called when the node enters the scene tree for the first time.
func _ready():
	_attack_delay_timmer = Timer.new()
	_attack_delay_timmer.wait_time = attack_delay
	_attack_delay_timmer.autostart = false
	_attack_delay_timmer.one_shot = true
	add_child(_attack_delay_timmer)
	
	_input_detection = preload("res://addons/Godot-Touch-Input-Manager/input_detection.tscn").instance()
	_input_detection.connect("any_gesture", self,"_on_input_detection_any_gesture")
	add_child(_input_detection)
	
	connect("input_event", self,"_on_unit_input_event")
	
func _on_unit_input_event(camera, event, position, normal, shape_idx):
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("unit_selected", self)
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta :float):
	attacking(delta)
	moving(delta)
	idle(delta)
	
func idle(delta :float):
	pass
	
func attacking(delta :float):
	if not is_attacking:
		return
		
	if not is_instance_valid(attack_to):
		is_attacking = false
		return
		
	var is_arrive :bool = _move_to_position(attack_to.global_transform.origin)
	if is_arrive and _attack_delay_timmer.is_stopped():
		perform_attack()
		_attack_delay_timmer.wait_time = attack_delay
		_attack_delay_timmer.start()
		
func perform_attack():
	if not is_instance_valid(attack_to):
		is_attacking = false
		return
		
	if attack_to.is_dead:
		is_attacking = false
		return
		
	attack_to.take_damage(attack_damage)
	
func take_damage(damage :int) -> void:
	if is_dead:
		return
		
	hp -= damage
	if hp < 1:
		is_dead = true
		emit_signal("unit_dead", self)
		return
		
	emit_signal("unit_take_damage", self, damage)
	
func moving(delta :float):
	if not is_moving:
		_velocity = Vector3.ZERO
		_velocity.y -= speed
		_velocity = move_and_slide(_velocity, Vector3.UP)
		return
	
	var is_arrive :bool = _move_to_position(move_to)
	if is_arrive:
		is_moving = false
	
func _move_to_position(to :Vector3) -> bool:
	var distance :float = translation.distance_to(to)
	if distance <= attack_range and is_attacking:
		return true
		
	if distance <= margin and is_moving:
		return true
		
	_direction = translation.direction_to(to)
	_velocity = _direction * speed
	_velocity.y -= speed
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	return false





