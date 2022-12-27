extends BaseEntity
class_name Squad

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

export var formation_space :int = 2

var _speed :int = 2
var _units :Array = []
var _targets :Array = []
var _velocity :Vector3

puppet var _puppet_translation :Vector3

onready var _input_detection = $input_detection
onready var _sprite_3d =  $banner/Sprite3D
onready var _agro_timer = $agro_timer
onready var _unit_count = $banner/unit_count
onready var _hit_particle = $hit_particle

# Called when the node enters the scene tree for the first time.
func _ready():
	_sprite_3d.modulate = color
	var text_mesh :TextMesh = _unit_count.mesh.duplicate()
	
	_unit_count.mesh = text_mesh
	(_unit_count.mesh as TextMesh).text = str(max_unit)
	
	var formations = get_formation_box()
	var pos = 0
	for i in range(max_unit):
		var _unit = unit.instance()
		_unit.team = team
		_unit.color = color
		_unit.connect("unit_selected", self, "_unit_selected")
		_unit.connect("unit_dead", self, "_unit_dead")
		_unit.connect("unit_take_damage", self, "_unit_take_damage")
		add_child(_unit)
		
		_unit.set_as_toplevel(true)
		_unit.translation = formations[pos] + Vector3(0, 2, 0)
		_units.append(_unit)
		
		_speed = _unit.speed
		pos += 1
		
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
		queue_free()
		
	emit_signal("squad_update", self)
		
func _on_formation_time_timeout():
	var formations = get_formation_box()
	for i in range(_units.size()):
		if not is_instance_valid(_units[i]):
			continue
			
		if _targets.empty():
			_units[i].is_attacking = false
			
		if _units[i].is_attacking:
			continue
			
		_units[i].is_moving = true
		_units[i].move_to = formations[i]
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	if not is_moving:
		return
		
	_velocity = Vector3.ZERO

	var is_arrive :bool = _move_to_position(move_to)
	if is_arrive:
		is_moving = false
	
	_velocity.y -= _speed
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	translation = translation.linear_interpolate(_puppet_translation, 5 * delta)
	
func _move_to_position(to :Vector3) -> bool:
	var distance :float = translation.distance_to(to)
	if distance <= margin:
		return true
		
	var direction :Vector3 = translation.direction_to(to)
	_velocity = direction * _speed
	_velocity.y = 0
	
	return false
	
func _on_squad_input_event(camera, event, position, normal, shape_idx):
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("squad_selected", self)
		
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

func attack_targets():
	if _targets.empty():
		return
		
	for i in range(_targets.size()):
		if i > 2:
			return
			
		if i < _units.size():
			if not is_instance_valid(_units[i]):
				_units.remove(i)
				return
				
			if not is_instance_valid(_targets[i]):
				_targets.remove(i)
				return
				
			_units[i].is_moving = false
			_units[i].is_attacking = true
			_units[i].attack_to = _targets[i]


func _on_Area_body_entered(body):
	if body == self:
		return
		
	if body is BaseUnit:
		if body in _units:
			return
			
		if body.team == team:
			return
			
		_targets.append(body)
		
	_agro_timer.start()

func _on_Area_body_exited(body):
	if body in _targets:
		_targets.erase(body)
		
func _on_agro_timer_timeout():
	if not _targets.empty():
		_agro_timer.start()
	else:
		_agro_timer.stop()
		
	attack_targets()



