extends BaseEntity
class_name Squad

signal squad_selected(_squad)
signal squad_dead(_squad)

export var unit :Resource
export var team :int = 0
export var color :Color = Color.white
export var max_unit :int = 16

var units :Array = []
var targets :Array = []

export var is_moving :bool = false
export var move_to :Vector3
export var margin :float = 0.3
export var speed :int = 2

var _velocity :Vector3

puppet var _puppet_translation :Vector3
onready var _input_detection = $input_detection
onready var _sprite_3d = $Sprite3D
onready var _agro_timer = $agro_timer
onready var _unit_count = $unit_count

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
		add_child(_unit)
		
		_unit.set_as_toplevel(true)
		_unit.translation = formations[pos] + Vector3(0, 2, 0)
		units.append(_unit)
		pos += 1
		
func _unit_selected(_unit):
	emit_signal("squad_selected", self)
	
func _unit_dead(_unit):
	rpc("_erase_unit", _unit.get_path())
	
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		
remotesync func _erase_unit(_unit_path :NodePath):
	var _unit :BaseUnit = get_node_or_null(_unit_path)
	if not is_instance_valid(_unit):
		return
		
	units.erase(_unit)
	_unit.queue_free()
	
	(_unit_count.mesh as TextMesh).text = str(units.size())
	
	if units.empty():
		emit_signal("squad_dead", self)
		queue_free()
		
func moving(_delta :float) -> void:
	var formations = get_formation_box()
	for i in range(units.size()):
		if not is_instance_valid(units[i]):
			continue
			
		if units[i].is_attacking and not targets.empty():
			continue
			
		units[i].is_moving = true
		units[i].move_to = formations[i]
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if not is_moving:
		return
	
	var is_arrive :bool = _move_to_position(move_to)
	if is_arrive:
		is_moving = false
		return
		
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	translation = translation.linear_interpolate(_puppet_translation, 5 * delta)
	
func _move_to_position(to :Vector3) -> bool:
	var distance :float = translation.distance_to(to)
	if distance <= margin:
		return true
		
	var direction :Vector3 = translation.direction_to(to)
	_velocity = direction * speed
	_velocity.y -= speed
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	return false
	
func _on_squad_input_event(camera, event, position, normal, shape_idx):
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("squad_selected", self)
		
func get_formation_box(space : int = 1):
	var formations = []
	var pos = global_transform.origin
	var s_side = round(sqrt(max_unit))
	var unit_pos = pos - space * Vector3(s_side/2,pos.y, s_side/2)
	for i in max_unit:
		formations.append(unit_pos)
		unit_pos.x += space
		if unit_pos.x > (pos.x + s_side * space / 2):
			unit_pos.z += space
			unit_pos.x = pos.x - space * s_side / 2
			
	return formations

func attack_targets():
	if targets.empty():
		return
		
	for i in range(targets.size()):
		if i > 2:
			return
			
		if i < units.size():
			if not is_instance_valid(units[i]):
				units.remove(i)
				return
				
			if not is_instance_valid(targets[i]):
				targets.remove(i)
				return
				
			units[i].is_moving = false
			units[i].is_attacking = true
			units[i].attack_to = targets[i]


func _on_Area_body_entered(body):
	if body == self:
		return
		
	if body is BaseUnit:
		if body in units:
			return
			
		if body.team == team:
			return
			
		targets.append(body)
		
	_agro_timer.start()

func _on_Area_body_exited(body):
	if  body in targets:
		targets.erase(body)
		
func _on_agro_timer_timeout():
	if not targets.empty():
		_agro_timer.start()
	else:
		_agro_timer.stop()
		
	attack_targets()
