extends BaseEntity
class_name Squad

signal squad_selected(_squad)
signal squad_update(_squad)
signal squad_dead(_squad)

export var unit :Resource
export var team :int = 0
export var color :Color = Color.white
export var max_unit :int = 8

export var is_moving :bool = false
export var move_to :Vector3
export var margin :float = 1

export var formation_space :int = 1

var _is_range_squad :bool = false
var _speed :int = 2
var _units :Array = []
var _targets :Array = []
var _velocity :Vector3

puppet var _puppet_translation :Vector3

onready var _input_detection = $input_detection
onready var _banner = $banner/banner
onready var _agro_timer = $agro_timer
onready var _unit_count = $banner/unit_count
onready var _hit_particle = $hit_particle
onready var _spotting_area = $Area/CollisionShape
onready var _area = $Area

# Called when the node enters the scene tree for the first time.
func _ready():
	var spotting_range :int = 8
	
	var banner_mesh_material :SpatialMaterial = _banner.get_surface_material(0).duplicate()
	var text_mesh :TextMesh = _unit_count.mesh.duplicate()
	
	_unit_count.mesh = text_mesh
	_banner.set_surface_material(0, banner_mesh_material)
	
	(_unit_count.mesh as TextMesh).text = str(max_unit)
	banner_mesh_material.albedo_color = color
	banner_mesh_material.albedo_color.a = 0.6
	
	var formations = get_formation_box()
	var pos = 0
	for i in range(max_unit):
		var _unit = unit.instance()
		_unit.name = "unit-" + str(pos)
		_unit.set_network_master(get_network_master())
		_unit.team = team
		_unit.color = color
		_unit.connect("unit_selected", self, "_unit_selected")
		_unit.connect("unit_dead", self, "_unit_dead")
		_unit.connect("unit_take_damage", self, "_unit_take_damage")
		add_child(_unit)
		_unit.set_as_toplevel(true)
		_unit.translation = formations[pos] + Vector3(0, 2, 0)
		_units.append(_unit)
		
		_speed = (_unit.speed + 1)
		spotting_range = _unit.spotting_range
		_is_range_squad = _unit.is_range_unit
		pos += 1
		
		
	var shape :CylinderShape = _spotting_area.shape.duplicate() as CylinderShape
	shape.radius = spotting_range
	_spotting_area.shape = shape
	
func _unit_selected(_unit):
	emit_signal("squad_selected", self)
	
func _unit_take_damage(_unit :BaseUnit, _damage :int):
	rpc_unreliable("_damage_unit", _unit.get_path(), _damage)
	
func _unit_dead(_unit :BaseUnit):
	rpc("_erase_unit", _unit.get_path())
	
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		
remotesync func _damage_unit(_unit_path :NodePath, _damage :int):
	var _unit :BaseUnit = get_node_or_null(_unit_path)
	if not is_instance_valid(_unit):
		return
		
	_hit_particle.translation = _unit.global_transform.origin
	_hit_particle.display_hit("-" + str(_damage))
	
remotesync func _erase_unit(_unit_path :NodePath):
	var _unit :BaseUnit = get_node_or_null(_unit_path)
	if not is_instance_valid(_unit):
		return
		
	_units.erase(_unit)
	_unit.queue_free()
	
	(_unit_count.mesh as TextMesh).text = str(_units.size())
	
	if _units.empty():
		emit_signal("squad_dead", self)
		set_process(false)
		queue_free()
		return
		
	emit_signal("squad_update", self)
		
func _on_formation_time_timeout():
	if _units.empty():
		return
		
	var formations = get_formation_box()
	for i in range(_units.size()):
		if not is_instance_valid(_units[i]):
			continue
			
		if _targets.empty():
			_units[i].is_attacking = false
			_units[i].attack_to = null
			
		if _units[i].is_attacking:
			continue
			
		_units[i].is_moving = true
		_units[i].move_to = formations[i]
		
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	_velocity = Vector3.ZERO
	
	if is_moving:
		var is_arrive :bool = _move_to_position(move_to)
		if is_arrive:
			is_moving = false
			
	if not is_on_floor():
		_velocity.y -= _speed
		_velocity = move_and_slide(_velocity, Vector3.UP, true)
		
	else:
		_velocity = move_and_slide(_velocity, Vector3.UP, true)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	translation = translation.linear_interpolate(_puppet_translation, 5 * delta)
	
func _move_to_position(to :Vector3) -> bool:
	var pos = global_transform.origin
	var distance :float = pos.distance_to(to)
	if distance <= margin:
		return true
		
	var direction :Vector3 = pos.direction_to(to)
	_velocity = direction * _speed
	_velocity.y = 0
	
	return false
	
func _on_squad_input_event(camera, event, position, normal, shape_idx):
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("squad_selected", self)
		
func set_selected(val :bool):
	for unit in _units:
		if not is_instance_valid(unit):
			continue
			
		unit.set_selected(val)
		
func get_formation_box():
	var formations = []
	var pos = global_transform.origin
	var s_side = round(sqrt(max_unit))
	var unit_pos = pos - formation_space * Vector3(s_side/2,pos.y, s_side/2)
	
	for i in max_unit:
		unit_pos.y = pos.y
		formations.append(unit_pos)
		unit_pos.x += formation_space
		if unit_pos.x > (pos.x + s_side * formation_space / 2):
			unit_pos.z += formation_space
			unit_pos.x = pos.x - formation_space * s_side / 2
			
	return formations

func _attack_targets():
	if _targets.empty() or _units.empty():
		return
		
	var max_attack_unit :int = 2
	
	if _is_range_squad:
		max_attack_unit = _units.size()
		
	else:
		max_attack_unit = int(_units.size() / 2)
		max_attack_unit = 2 if max_attack_unit < 2 else max_attack_unit
	
	var pos :int = 0
	
	for unit in _units:
		if pos >= max_attack_unit:
			return
			
		if not is_instance_valid(_targets[pos]):
			_targets.remove(pos)
			return
			
		if is_instance_valid(unit):
			unit.is_moving = false
			unit.is_attacking = true
			unit.attack_to = _targets[pos]
			
		if pos < _targets.size() - 1:
			pos += 1
	
func _spotted_target():
	_targets.clear()
	
	for body in _area.get_overlapping_bodies():
		if _targets.size() > 32:
			return
			
		if body == self:
			continue
			
		if body is BaseUnit:
			if body in _units:
				continue
				
			if body.team == team:
				continue
				
			_targets.append(body)
			
func _on_agro_timer_timeout():
	_spotted_target()
	_attack_targets()



