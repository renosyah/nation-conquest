extends BaseBuilding
class_name ArcherTower

export var unit :Resource
export var max_unit :int = 4

onready var _collision_shape = $CollisionShape

onready var _garrison_position = $Position3D
onready var _spotting_area = $Area/CollisionShape
onready var _area = $Area
onready var _hp_bar = $hpBar

onready var _mesh_instance = $MeshInstance
onready var _mesh_instance_2 = $MeshInstance2

onready var _mesh_instance_2_material = _mesh_instance_2.get_surface_material(0).duplicate()

onready var _area_build = $area_build

onready var _tween = $Tween

var _units :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_hp_bar.visible = false
	
	_mesh_instance.visible = false
	_mesh_instance_2.visible = true
	
	var _team_color_material :SpatialMaterial = _mesh_instance.get_surface_material(2).duplicate()
	_team_color_material.albedo_color = color
	_mesh_instance.set_surface_material(2, _team_color_material)
	
	for i in range(_mesh_instance_2.get_surface_material_count()):
		_mesh_instance_2.set_surface_material(i, _mesh_instance_2_material)
		
	_area_build.input_ray_pickable = is_selectable
	
	set_process(true)
	
remotesync func _start_building():
	._start_building()
	
	_mesh_instance.visible = true
	_mesh_instance.translation.y -= 10
	_collision_shape.set_deferred("disabled", false)
	
	_tween.interpolate_property(
		_mesh_instance, "translation:y", _mesh_instance.translation.y,
		 _mesh_instance.translation.y + 10, building_time
	)
	_tween.start()
	
	
	
remotesync func _finish_building():
	._finish_building()
	
	_mesh_instance_2.visible = false
	var attack_range = 8
	for pos in range(max_unit):
		var _unit = _create_unit("garrison-unit-" + str(pos))
		_unit.global_transform.origin = get_garrison_spawn_pos()
		_unit.global_rotation = Vector3.ZERO
		_units.append(_unit)
		
		attack_range = _unit.attack_range
		
	var shape :CylinderShape = _spotting_area.shape.duplicate() as CylinderShape
	shape.radius = attack_range + 2
	_spotting_area.shape = shape
	
	_hp_bar.update_bar(hp, max_hp)
	_hp_bar.visible = true
	
remotesync func _take_damage(damage :int, hp_remain :int) -> void:
	._take_damage(damage, hp_remain)
	_hp_bar.update_bar(hp, max_hp)
	
func get_garrison_spawn_pos() -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(0.5, 1)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 =_garrison_position.global_transform.origin + Vector3(posv2.x, 0, posv2.y)
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
		
	rpc("_spawn_garrison", GDUUID.v4())
		
remotesync func _spawn_garrison(_node_name :String):
	var _unit = _create_unit(_node_name)
	_unit.global_transform.origin = get_garrison_spawn_pos()
	_unit.global_rotation = Vector3.ZERO
	_units.append(_unit)
	
func _create_unit(unit_name :String) -> BaseUnit:
	var _unit :BaseUnit = unit.instance()
	_unit.name = unit_name
	_unit.is_master = _is_network_master()
	_unit.team = team
	_unit.hp = 200
	_unit.max_hp = 200
	_unit.attack_range += 2
	_unit.attack_delay = 3
	_unit.color = color
	_unit.enable_moving = false
	_unit.connect("unit_dead", self, "_unit_dead")
	_unit.set_as_toplevel(true)
	add_child(_unit)
	return _unit
	
func moving(_delta :float) -> void:
	if status == status_deploying:
		can_build = _area_build.get_overlapping_bodies().empty() and translation.distance_to(base_position) < max_distance_from_base
		_mesh_instance_2_material.albedo_color = Color(1,1,1,0.5) if can_build else Color(1,0,0,0.5)
	

func _unit_dead(_unit :BaseUnit):
	rpc("_erase_unit", _unit.get_path())
	
remotesync func _erase_unit(_unit_path :NodePath):
	var _unit :BaseUnit = get_node_or_null(_unit_path)
	if not is_instance_valid(_unit):
		return
		
	_units.erase(_unit)
	_unit.queue_free()
	
func _spotted_target() -> Array:
	var _targets :Array = []
	var _unit_size = _units.size()
	
	for body in _area.get_overlapping_bodies():
		if _targets.size() > _unit_size:
			return _targets
			
		if body is BaseUnit:
			if body in _units:
				continue
				
			if body.team == team:
				continue
				
			_targets.append(body.get_path())
			
	return _targets
	
func _on_agro_timer_timeout():
	if is_dead:
		return
		
	if status != status_deployed:
		return
		
	if _is_master:
		var targets :Array = _spotted_target()
		rpc("_attack_targets", targets)
	
remotesync func _attack_targets(_targets :Array):
	if _units.empty():
		return
		
	if _targets.empty():
		for _unit in _units:
			if is_instance_valid(_unit):
				_unit.is_attacking = false
				_unit.attack_to = null
		return
		
	var pos :int = 0
	for _unit in _units:
		if is_instance_valid(_unit):
			_unit.attack_target(
				get_node_or_null(_targets[pos])
			)
			
		if pos < _targets.size() - 1:
			pos += 1
	
func _on_area_build_input_event(camera, event, position, normal, shape_idx):
	._on_input_event(camera, event, position, normal, shape_idx)
