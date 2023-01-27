extends KinematicBody
class_name BaseUnit

signal unit_take_damage(_unit, _damage)
signal unit_dead(_unit)

export var is_dead :bool = false
export var team :int = 0
export var color :Color = Color.white
export var hp :int = 5
export var max_hp :int = 5

export var enable_moving :bool = true

export var is_moving :bool = false
var move_to = null
export var margin :float = 0.8
export var speed :int = 2

var squad = null

var _direction :Vector3 = Vector3.ZERO
var _velocity :Vector3 = Vector3.ZERO
var _up_direction :Vector3 = Vector3.UP

export var is_attacking :bool = false
var attack_to = null
export var attack_damage :int = 1
export var attack_delay :float = 1
export var attack_range :float = 2
export var spotting_range :float = 8
export(float, 0.0 , 1.0) var skill :float = 0.2

export var unit_tier :int
export var unit_role :int

export var is_master :bool = false

var _attack_delay_timmer :Timer
var _stun_delay_timmer :Timer
var _sound :AudioStreamPlayer3D
var _higlight :UnitHighlight

onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")
onready var _counter :CounterData = CounterData.new(unit_role, unit_tier, skill)
onready var _damage_modifier :int = attack_damage

# Called when the node enters the scene tree for the first time.
func _ready():
	_attack_delay_timmer = Timer.new()
	_attack_delay_timmer.wait_time = attack_delay
	_attack_delay_timmer.autostart = false
	_attack_delay_timmer.one_shot = true
	add_child(_attack_delay_timmer)
	
	_stun_delay_timmer = Timer.new()
	_stun_delay_timmer.wait_time = 1.2
	_stun_delay_timmer.autostart = false
	_stun_delay_timmer.one_shot = true
	add_child(_stun_delay_timmer)
	
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	
	_higlight = preload("res://assets/unit_highlight/unit_highlight.tscn").instance()
	add_child(_higlight)
	_higlight.translation.y -= 0.3
	_higlight.visible = false
	
	input_ray_pickable = false
	
func set_selected(val :bool):
	_higlight.visible = val
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta :float):
	if is_dead:
		return
		
	_direction = Vector3.ZERO
	_up_direction = Vector3.UP
	_velocity = Vector3.ZERO
	
	attacking(delta)
	moving(delta)
	idle(delta)
	
	if not enable_moving:
		return
		
	if not is_on_floor():
		_velocity.y = -_gravity
	else:
		_up_direction = get_floor_normal()
	
	if _velocity != Vector3.ZERO:
		_velocity = move_and_slide(
			_velocity, _up_direction, true, 4, deg2rad(45.0), true
		)
		
func attack_target(_attack_to):
	if not is_instance_valid(_attack_to):
		return
		
	attack_to = _attack_to
	is_attacking = true
	is_moving = false
	
	if attack_to is BaseBuilding:
		_damage_modifier = attack_damage / 2
		
	else:
		_damage_modifier = _counter.get_attack_modifier(
			attack_to.unit_tier, 
			attack_to.unit_role,
			attack_damage
		)
	
func keep_moving():
	is_attacking = false
	attack_to = null
	is_moving = true
	
func attacking(delta :float):
	if not is_attacking:
		return
		
	if not is_instance_valid(attack_to):
		keep_moving()
		return
		
	if is_instance_valid(squad):
		if squad.is_moving:
			keep_moving()
			return
			
	var is_arrive :bool = false
	
	if enable_moving:
		is_arrive = _move_to_position(
			attack_to.global_transform.origin, attack_range
		)
	else:
		is_arrive = true
	
	in_combat(is_arrive)
	
func in_combat(is_arrive :bool):
	if is_arrive and _attack_delay_timmer.is_stopped():
		perform_attack()
		_attack_delay_timmer.wait_time = _randomize_attack_delay()
		_attack_delay_timmer.start()
		
func moving(delta :float):
	if not enable_moving:
		return
		
	if not is_moving:
		return
		
	if not is_instance_valid(move_to):
		return
		
	var is_arrive :bool = _move_to_position(
		move_to.global_transform.origin, margin
	)
	
	if not is_arrive:
		return
		
	is_moving = false
	
func idle(delta :float):
	pass
	
func perform_attack():
	if not is_instance_valid(attack_to):
		keep_moving()
		return
		
	if attack_to.is_dead:
		keep_moving()
		return
		
	if not is_master:
		return
		
	attack_to.take_damage(_damage_modifier)
	
func take_damage(damage :int) -> void:
	if is_dead:
		return
		
	if _stun_delay_timmer.is_stopped():
		_stun_delay_timmer.wait_time = 1 + damage
		_stun_delay_timmer.start()
		
	hp -= damage
	if hp < 1:
		set_process(false)
		is_dead = true
		dead()
		return
		
	emit_signal("unit_take_damage", self, damage)
	
func dead() -> void:
	emit_signal("unit_dead", self)
	
func get_prediction_path() -> Vector3:
	return global_transform.origin + _velocity
	
func _move_to_position(_at :Vector3, _margin :float) -> bool:
	var pos :Vector3 = global_transform.origin
	var to :Vector3 = Vector3(_at.x , pos.y, _at.z)
	var distance :float = pos.distance_to(to)
	if distance <= _margin:
		return true
	
	var _speed_modifer = speed * distance if is_moving and distance > 0 else speed
	if not _stun_delay_timmer.is_stopped():
		_speed_modifer = _speed_modifer * 0.25
		
	_speed_modifer = clamp(_speed_modifer, 0, 5)
	
	_direction = translation.direction_to(to)
	_velocity = _direction * _speed_modifer
	_velocity.y = 0
	
	return false
	
func _randomize_attack_delay() -> float:
	var fraction = attack_delay * 0.25
	var attack_time = attack_delay + rand_range(-0.2, fraction) - skill
	return attack_time if attack_time > 0 else 1

func _turn_spatial_pivot_to_attack(_spatial :Spatial, delta :float):
	if not is_attacking:
		return
		
	if not is_instance_valid(attack_to):
		return
		
	var global_target_pos :Vector3 = attack_to.global_transform.origin
	var global_pos :Vector3 = global_transform.origin
	var global_target_pos_y_normalize :Vector3 = Vector3(
		global_target_pos.x, global_pos.y, global_target_pos.z
	)
	var distance_squared :float = global_pos.distance_squared_to(global_target_pos_y_normalize)
	if distance_squared < 10.0:
		return
		
	var _transform :Transform = _spatial.transform.looking_at(
		global_pos.direction_to(global_target_pos_y_normalize) * 100, Vector3.UP
	)
	_spatial.transform = _spatial.transform.interpolate_with(_transform, 5 * delta)
	
func _turn_spatial_pivot_to_moving(_spatial :Spatial, delta :float):
	if not is_moving:
		return
		
	if _direction == Vector3.ZERO:
		return
		
	var _transform :Transform = _spatial.transform.looking_at(_direction * 100, Vector3.UP)
	_spatial.transform = _spatial.transform.interpolate_with(_transform, 5 * delta)
