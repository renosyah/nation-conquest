extends BaseEntity
class_name Squad

const squad_selected_color :Color = Color(1, 1, 1, 1)
const squad_unselected_color :Color = Color(1, 1, 1, 0.2)

signal squad_selected(_squad)
signal squad_update(_squad)
signal squad_dead(_squad)

export var unit :Resource
export var team :int = 0
export var color :Color = Color.white
export var max_unit :int = 15

export var is_moving :bool = false
export var move_to :Vector3
export var margin :float = 0.3

export var formation_space :int = 1

export var is_dead :bool = false

var _speed :int = 2
var _units :Array = []
var _targets :Array = []
var _velocity :Vector3

puppet var _puppet_is_moving :bool
puppet var _puppet_translation :Vector3
puppet var _puppet_velocity :Vector3

onready var _input_detection = $input_detection
onready var _banner = $banner/banner
onready var _agro_timer = $agro_timer
onready var _unit_count = $banner/unit_count
onready var _hit_particle = $hit_particle
onready var _spotting_area = $Area/CollisionShape
onready var _area = $Area
onready var _outline = $banner/outline
onready var _pivot = $pivot
onready var _visibility_notifier = $VisibilityNotifier
onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	is_dead = true
	
	var spotting_range :int = 8
	
	var banner_mesh_material :SpatialMaterial = _banner.get_surface_material(0).duplicate()
	var text_mesh :TextMesh = _unit_count.mesh.duplicate()
	var outline_mesh_material :SpatialMaterial = _outline.get_surface_material(0).duplicate()
	
	_unit_count.mesh = text_mesh
	_banner.set_surface_material(0, banner_mesh_material)
	_outline.set_surface_material(0, outline_mesh_material)
	
	(_unit_count.mesh as TextMesh).text = str(max_unit)
	banner_mesh_material.albedo_color = color
	banner_mesh_material.albedo_color.a = 0.6
	
	outline_mesh_material.albedo_color = squad_unselected_color
	
	var formations = get_formation_box()
	for pos in formations:
		var position3d = Position3D.new()
		_pivot.add_child(position3d)
		position3d.translation = pos
		
	var delay = Timer.new()
	delay.wait_time = 1
	add_child(delay)
	delay.start()
	
	yield(delay, "timeout")
	delay.queue_free()
	
	for pos in range(max_unit):
		var _unit = unit.instance()
		_unit.name = "unit-" + str(pos)
		_unit.is_master = _is_master()
		_unit.team = team
		_unit.color = color
		_unit.connect("unit_selected", self, "_unit_selected")
		_unit.connect("unit_dead", self, "_unit_dead")
		_unit.connect("unit_take_damage", self, "_unit_take_damage")
		_unit.move_to = _pivot.get_child(pos)
		_unit.is_moving = true
		_unit.squad = self
		add_child(_unit)
		_unit.set_as_toplevel(true)
		_unit.translation = _pivot.get_child(pos).global_transform.origin + Vector3(0, 2, 0)
		_units.append(_unit)
		
		_speed = _unit.speed + 1
		spotting_range = _unit.spotting_range
		
	var shape :CylinderShape = _spotting_area.shape.duplicate() as CylinderShape
	shape.radius = spotting_range
	_spotting_area.shape = shape
	
	_visibility_notifier.connect("camera_entered", self, "_on_VisibilityNotifier_camera_entered")
	_visibility_notifier.connect("camera_exited", self, "_on_VisibilityNotifier_camera_exited")
	
	visible = true
	is_dead = false
	
func _unit_selected(_unit):
	emit_signal("squad_selected", self)
	
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
		is_dead = true
		set_process(false)
		rpc("_squad_disband")
		return
		
	emit_signal("squad_update", self)
		
		
remotesync func _squad_disband():
	is_dead = true
	set_process(false)
	emit_signal("squad_dead", self)
	queue_free()

func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
	
	_velocity = Vector3.ZERO
	
	if is_moving:
		var is_arrive :bool = _move_to_position(move_to)
		if is_arrive:
			is_moving = false
		
	if not is_on_floor():
		_velocity.y -= _gravity
		
	if _velocity != Vector3.ZERO:
		_velocity = move_and_slide(_velocity, Vector3.UP, true)
		
	_formation_direction_facing(delta)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	translation = translation.linear_interpolate(_puppet_translation, 5 * delta)
	_velocity = _puppet_velocity
	is_moving = _puppet_is_moving
	
	_formation_direction_facing(delta)
	
func _formation_direction_facing(delta :float):
	var _vel = Vector3(_velocity.x, 0 , _velocity.z)
	if _vel != Vector3.ZERO:
		var _transform = _pivot.transform.looking_at(_vel, Vector3.UP)
		_pivot.transform = _pivot.transform.interpolate_with(_transform, 10 * delta)
		
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
		
	var color :Color = squad_selected_color if val else squad_unselected_color
	(_outline.get_surface_material(0) as SpatialMaterial).albedo_color = color
		
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
	if _units.empty():
		return
		
	if _targets.empty():
		for unit in _units:
			if is_instance_valid(unit):
				unit.is_moving = true
				unit.is_attacking = false
				unit.attack_to = null
		return
		
	var pos :int = 0
	for unit in _units:
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


func _on_VisibilityNotifier_camera_entered(camera):
	visible = true

func _on_VisibilityNotifier_camera_exited(camera):
	visible = false
