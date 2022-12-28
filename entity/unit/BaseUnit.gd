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
export var margin :float = 0.6
export var speed :int = 2

var _direction :Vector3
var _velocity :Vector3

export var is_attacking :bool = false
var attack_to = null
export var attack_damage :int = 1
export var attack_delay :float = 0.4
export var attack_range :float = 1
export var spotting_range :float = 8

var _attack_delay_timmer :Timer
var _input_detection :Node
var _sound :AudioStreamPlayer3D

onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	_attack_delay_timmer = Timer.new()
	_attack_delay_timmer.wait_time = attack_delay
	_attack_delay_timmer.autostart = false
	_attack_delay_timmer.one_shot = true
	add_child(_attack_delay_timmer)
	
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	
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
	_velocity = Vector3.ZERO
	_direction = Vector3.ZERO
	
	attacking(delta)
	moving(delta)
	idle(delta)
	
	if not is_on_floor():
		_velocity.y -= _gravity
		_velocity = move_and_slide(_velocity, Vector3.UP, true)
		
	else:
		_velocity = move_and_slide(_velocity, Vector3.UP, true)
	
func attacking(delta :float):
	if not is_attacking:
		return
		
	if not is_instance_valid(attack_to):
		is_attacking = false
		return
		
	var is_arrive = _move_to_position(
		attack_to.global_transform.origin, attack_range
	)
	if is_arrive:
		if _attack_delay_timmer.is_stopped():
			perform_attack()
			_attack_delay_timmer.wait_time = attack_delay
			_attack_delay_timmer.start()
		
func moving(delta :float):
	if not is_moving:
		return
	
	var is_arrive = _move_to_position(move_to, margin)
	if is_arrive:
		is_moving = false
	
func idle(delta :float):
	pass
	
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
		set_process(false)
		is_dead = true
		dead()
		return
		
	emit_signal("unit_take_damage", self, damage)
	
func dead() -> void:
	emit_signal("unit_dead", self)
	
func _move_to_position(_at :Vector3, _margin :float) -> bool:
	var pos = global_transform.origin
	var to = Vector3(_at.x , pos.y, _at.z)
	var distance :float = pos.distance_to(to)
	if distance <= _margin:
		return true
		
	_direction = translation.direction_to(to)
	_velocity = _direction * speed
	_velocity.y = 0
	
	return false





