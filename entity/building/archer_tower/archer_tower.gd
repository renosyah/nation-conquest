extends BaseBuilding

export var unit :Resource
export var max_unit :int = 4

onready var _garrison_position = $Position3D
onready var _spotting_area = $Area/CollisionShape
onready var _area = $Area
onready var _hp_bar = $hpBar
onready var _hit_particle = $hit_particle

var _units :Array = []
var _targets :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var attack_range = 8
	for pos in range(max_unit):
		var _unit = _create_unit("garrison-unit-" + str(pos))
		_unit.translation = get_garrison_spawn_pos()
		_units.append(_unit)
		
		attack_range = _unit.attack_range
		
	var shape :CylinderShape = _spotting_area.shape.duplicate() as CylinderShape
	shape.radius = attack_range + 8
	_spotting_area.shape = shape
	
	_hp_bar.update_bar(hp, max_hp)
	
func get_garrison_spawn_pos() -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(0.5, 1)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 =_garrison_position.translation  + Vector3(posv2.x, 0, posv2.y)
	return posv3
	
func _on_garrison_replenis_timer_timeout():
	if is_dead:
		return
		
	if not _is_master:
		return
		
	if status != status_deployed:
		return
		
	if _units.size() >= max_unit:
		return
		
	rpc("_spawn_garrison", "garrison-unit-" + str(_units.size() + 1))
		
remotesync func _spawn_garrison(_node_name :String):
	var _unit = _create_unit(_node_name)
	_unit.translation = get_garrison_spawn_pos()
	_units.append(_unit)
	
func _create_unit(unit_name :String) -> BaseUnit:
	var _unit = unit.instance()
	_unit.name = unit_name
	_unit.is_master = _is_master()
	_unit.team = team
	_unit.hp = 200
	_unit.max_hp = 200
	_unit.attack_range += 8
	_unit.color = color
	_unit.enable_moving = false
	_unit.connect("unit_dead", self, "_unit_dead")
	add_child(_unit)
	return _unit
	
func take_damage(damage :int) -> void:
	.take_damage(damage)
	
	_hp_bar.update_bar(hp, max_hp)
	_hit_particle.display_hit(
		"-" + str(damage), Color.white,
		 _garrison_position.global_transform.origin
	)
	
	
func _unit_dead(_unit :BaseUnit):
	rpc("_erase_unit", _unit.get_path())
	
remotesync func _erase_unit(_unit_path :NodePath):
	var _unit :BaseUnit = get_node_or_null(_unit_path)
	if not is_instance_valid(_unit):
		return
		
	_units.erase(_unit)
	_unit.queue_free()
	
func _attack_targets():
	if _units.empty():
		return
		
	if _targets.empty():
		for unit in _units:
			if is_instance_valid(unit):
				unit.is_attacking = false
				unit.attack_to = null
		return
		
	var pos :int = 0
	for unit in _units:
		if is_instance_valid(unit):
			unit.is_attacking = true
			unit.attack_to = _targets[pos]
			
		if pos < _targets.size() - 1:
			pos += 1
	
func _spotted_target():
	_targets.clear()
	
	var _unit_size = _units.size()
	
	for body in _area.get_overlapping_bodies():
		if _targets.size() > _unit_size:
			return
			
		if body is BaseUnit:
			if body in _units:
				continue
				
			if body.team == team:
				continue
				
			_targets.append(body)
			
func _on_agro_timer_timeout():
	if is_dead:
		return
		
	_spotted_target()
	_attack_targets()
