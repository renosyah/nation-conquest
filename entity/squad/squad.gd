extends BaseEntity
class_name Squad

const squad_selected_color :Color = Color(1, 1, 1, 1)
const squad_unselected_color :Color = Color(1, 1, 1, 0.2)

signal squad_selected(_squad)
signal squad_unit_dead(_squad)
signal squad_unit_added(_squad)
signal squad_dead(_squad)

export var squad_name :String
export var squad_description :String
export var squad_icon :Resource

export var unit_scene :Resource
export var team :int = 0
export var color :Color = Color.white
export var max_unit :int = 15

export var is_moving :bool = false
export var move_to :Vector3
export var margin :float = 0.3
export var combat_range :int = 4
export var formation_space :int = 1

export var is_dead :bool = false
export var is_selectable :bool = false
export var is_assault_mode :bool = false

var _speed :int = 2
var _units :Array = []
var _targets :Array = []
var _velocity :Vector3

puppet var _puppet_is_moving :bool
puppet var _puppet_translation :Vector3
puppet var _puppet_velocity :Vector3
puppet var _puppet_targets :Array

onready var _input_detection = $input_detection
onready var _squad_banner = $squad_banner
onready var _hit_particle = $hit_particle

onready var _input_area = $squad_banner/input_area

onready var _spotting_area = $spotting_area
onready var _spotting_collision = $spotting_area/CollisionShape
onready var _pivot = $pivot
var _tap :Tap

onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")
onready var _floor_max_angle: float = deg2rad(45.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	is_dead = true
	
	_squad_banner.set_squad_number(max_unit)
	_squad_banner.set_player_name(
		player_name if not _is_master() and not player_name.empty() else ""
	)
	_squad_banner.set_banner_color(
		color, squad_unselected_color if is_selectable else Color.transparent
	)
	
	#_input_area.input_ray_pickable = is_selectable
	
	_tap = preload("res://assets/tap/tap.tscn").instance()
	var last_index = get_tree().get_root().get_child_count() - 1
	get_tree().get_root().get_child(last_index).add_child(_tap)
	_tap.color = color
	
	var formations = Utils.get_formation_box(
		global_transform.origin,max_unit,formation_space
	)
	for pos in formations:
		var position3d = Position3D.new()
		_pivot.add_child(position3d)
		position3d.translation = pos
		
	var spotting_range :int = 8
	
	for pos in range(max_unit):
		var _unit = _create_unit("unit-" + str(pos))
		_unit.move_to = _pivot.get_child(pos)
		_unit.is_moving = true
		_unit.translation = _pivot.get_child(pos).global_transform.origin + Vector3(0, 2, 0)
		_units.append(_unit)
		
		_speed = _unit.speed + 1
		spotting_range = _unit.spotting_range
		combat_range = _unit.spotting_range - 1
		
	var shape :CylinderShape = _spotting_collision.shape.duplicate() as CylinderShape
	shape.radius = spotting_range
	_spotting_collision.shape = shape
	_spotting_collision.set_deferred("disabled", not _is_master())
	
	var delay = Timer.new()
	delay.wait_time = 1
	add_child(delay)
	delay.start()
	
	yield(delay, "timeout")
	delay.queue_free()
	
	for _unit in _units:
		_unit.set_as_toplevel(true)
		
	_squad_banner.set_as_toplevel(true)
	
	is_dead = false
	
func _create_unit(unit_name :String) -> BaseUnit:
	var _unit = unit_scene.instance()
	_unit.name = unit_name
	_unit.is_master = _is_master()
	_unit.team = team
	_unit.color = color
	_unit.connect("unit_dead", self, "_unit_dead")
	_unit.connect("unit_take_damage", self, "_unit_take_damage")
	_unit.squad = self
	add_child(_unit)
	return _unit
	
func _reassign_unit_formation():
	for i in range(_units.size()):
		_units[i].is_moving = true
		_units[i].move_to = _pivot.get_child(i)
		
func _unit_take_damage(_unit :BaseUnit, _damage :int):
	rpc_unreliable("_damage_unit", _unit.get_path(), _damage)
	
func _unit_dead(_unit :BaseUnit):
	rpc("_erase_unit", _unit.get_path())
	
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if is_dead:
		return
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_velocity", _velocity)
		rset_unreliable("_puppet_is_moving", is_moving)
		rset_unreliable("_puppet_targets", _targets)
		
func _on_camera_entered(camera: Camera):
	._on_camera_entered(camera)
	
	for unit in _units:
		if not is_instance_valid(unit):
			continue
			
		unit.visible = true
		
func _on_camera_exited(camera: Camera):
	._on_camera_exited(camera)
	
	for unit in _units:
		if not is_instance_valid(unit):
			continue
			
		unit.visible = false
	
remotesync func _damage_unit(_unit_path :NodePath, _damage :int):
	if not visible:
		return
		
	var _unit :BaseUnit = get_node_or_null(_unit_path)
	if not is_instance_valid(_unit):
		return
		
	_hit_particle.display_hit(
		"-" + str(_damage), color,
		 _unit.global_transform.origin
	)
	
remotesync func _erase_unit(_unit_path :NodePath):
	var _unit :BaseUnit = get_node_or_null(_unit_path)
	if not is_instance_valid(_unit):
		return
		
	_units.erase(_unit)
	_unit.queue_free()
	
	_reassign_unit_formation()
	
	_squad_banner.set_squad_number(_units.size())
	_squad_banner.show_hurt()
	
	if _units.empty():
		is_dead = true
		set_process(false)
		
		if _is_master:
			rpc("_squad_disband")
		return
		
	emit_signal("squad_unit_dead", self)
		
		
remotesync func _reinforce_squad(_unit_name :String):
	for _unit in _units:
		if not is_instance_valid(_unit):
			continue
			
		_unit.hp = _unit.max_hp
	
	var _unit = _create_unit(_unit_name)
	_unit.set_as_toplevel(true)
	_unit.translation = global_transform.origin + Vector3(0, 2, 0)
	_units.append(_unit)
	
	_squad_banner.set_squad_number(_units.size())
	
	_reassign_unit_formation()
	emit_signal("squad_unit_added", self)
	
	
remotesync func _squad_disband():
	is_dead = true
	set_process(false)
	emit_signal("squad_dead", self)
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if is_dead:
		return
		
	_squad_banner.translation = _get_avg_units_position(global_transform.origin)
	_squad_banner.translation.y = global_transform.origin.y + 4
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
	
	_velocity = Vector3.ZERO
	
	_spotted_target()
	_attack_targets()
	
	if is_moving:
		var is_arrive :bool = _move_to_position(move_to)
		if is_arrive:
			is_moving = false
			return
		
	if not is_on_floor():
		_velocity.y -= _gravity
		
	if _velocity != Vector3.ZERO:
		_velocity = move_and_slide(
			_velocity, Vector3.UP , false, 4, deg2rad(60.0), true
		)
		
	_formation_direction_facing(delta)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	_targets = _puppet_targets
	_attack_targets()
	
	translation = translation.linear_interpolate(_puppet_translation, 5 * delta)
	_velocity = _puppet_velocity
	is_moving = _puppet_is_moving
	
	_formation_direction_facing(delta)
	
	
func _formation_direction_facing(delta :float):
	var _vel = Vector3(_velocity.x, 0, _velocity.z)
	if _vel != Vector3.ZERO:
		_pivot.look_at(_vel * 100, Vector3.UP)
		
func _move_to_position(_to :Vector3) -> bool:
	var pos :Vector3 = global_transform.origin
	var to :Vector3 = Vector3(_to.x, pos.y, _to.z)
	
	var distance :float = pos.distance_to(to)
	if distance <= margin:
		return true
		
	var direction :Vector3 = pos.direction_to(to)
	_velocity = direction * _speed
	_velocity.y = 0
	
	return false
	
func _on_input_area_input_event(camera, event, position, normal, shape_idx):
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("squad_selected", self)
		
func set_selected(val :bool):
	if not is_selectable:
		return
		
	for _unit in _units:
		if not is_instance_valid(_unit):
			continue
			
		_unit.set_selected(val)
		
	var outline_color :Color = squad_selected_color if val else squad_unselected_color
	_squad_banner.set_banner_color(color, outline_color)
	
func set_attack_to(to :Vector3, display_tap :bool = false):
	var combat_range_offset  = combat_range - 2
	var attack_pos :Vector3 = to.direction_to(global_transform.origin) * combat_range_offset
	var distance_to_target :float = global_transform.origin.distance_to(to)
	if distance_to_target < combat_range_offset:
		is_moving = false
		return
		
	set_move_to(to + attack_pos, display_tap)
	
func set_move_to(to :Vector3, display_tap :bool = false):
	move_to = to
	is_moving = true
	
	if display_tap:
		_tap.translation = move_to
		_tap.tap()
	
func is_in_combat() -> bool:
	return not _targets.empty()
	
func unit_size() -> int:
	return _units.size()
	
func reinforce_squad() -> void:
	if not _is_master:
		return
		
	if unit_size() >= max_unit:
		return
		
	rpc("_reinforce_squad", "unit-" +  GDUUID.v4())
	
func disband():
	if not _is_master:
		return
		
	rpc("_squad_disband")

func _attack_targets():
	if _units.empty():
		return
		
	if _targets.empty():
		for _unit in _units:
			if not is_instance_valid(_unit):
				continue
				
			if not _unit.is_attacking:
				continue
				
			_unit.is_attacking = true
			_unit.attack_to = null
			
		return
		
	if is_moving and is_assault_mode:
		is_moving = false
		is_assault_mode = false
		
	var pos :int = 0
	for _unit in _units:
		if _is_unit_idle(_unit):
			_unit.is_moving = false
			_unit.is_attacking = true
			_unit.attack_to = get_node_or_null(_targets[pos])
			
		if pos < _targets.size() - 1:
			pos += 1
	
func _is_unit_idle(_unit :BaseUnit) -> bool:
	if not is_instance_valid(_unit):
		return false
		
	if _unit.is_moving:
		return false
		
	return true
	
func _get_avg_units_position(default_pos :Vector3) -> Vector3:
	var sum_pos :Vector3 = Vector3.ZERO
	var unit_size :int = 0
	
	for _unit in _units:
		if is_instance_valid(_unit):
			sum_pos += _unit.global_transform.origin
			unit_size += 1
			
	if unit_size == 0:
		return default_pos
		
	return sum_pos / unit_size
	
func _spotted_target():
	_targets.clear()
	
	if _units.empty():
		return
		
	var _unit_size :int = unit_size()
	
	for body in _spotting_area.get_overlapping_bodies():
		if _targets.size() > _unit_size:
			return
			
		if body is BaseUnit:
			if body in _units:
				continue
				
			if body.team == team:
				continue
				
			if body.is_dead:
				continue
				
			_targets.append(body.get_path())
			
		elif body is BaseBuilding:
			if body.team == team:
				continue
				
			if body.is_dead:
				continue
				
			_targets.append(body.get_path())
			
func _on_squad_tree_exiting():
	if is_instance_valid(_tap):
		_tap.queue_free()
	
	
	
	












