extends BaseEntity
class_name BaseBuilding

signal building_selected(_building)
signal building_deployed(_building)
signal building_take_damage(_building, _damage)
signal building_destroyed(_building)

const status_deploying = 0
const status_building = 1
const status_deployed = 2

export var building_id :int = 0
export var team :int = 0
export var color :Color = Color.white

export var hp :int = 500
export var max_hp :int = 500

export var building_time :int = 10

export var is_dead :bool = false
export var status :int = status_deploying
export var can_build :bool = false
export var base_position :Vector3
export var is_selectable :bool = false
export var max_distance_from_base :int

puppet var _puppet_translation :Vector3
puppet var _puppet_rotation :Vector3

var _building_timmer :Timer

############################################################
# multiplayer func
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if is_dead:
		return
		
	if [status_deployed, status_building].has(status):
		return
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
	
# Called when the node enters the scene tree for the first time.
func _ready():
	status = status_deploying
	
	_building_timmer = Timer.new()
	_building_timmer.wait_time = building_time
	_building_timmer.connect("timeout", self , "_building_timmer_timeout")
	_building_timmer.autostart = false
	_building_timmer.one_shot = true
	add_child(_building_timmer)
	
	input_ray_pickable = is_selectable
	
	set_process(true)
	
func start_building():
	if not _is_master:
		return
		
	rpc("_start_building")
	
remotesync func _start_building():
	status = status_building
	_building_timmer.wait_time = building_time
	_building_timmer.start()
	_disable_process()
	
remotesync func _finish_building():
	status = status_deployed
	_disable_process()
	emit_signal("building_deployed", self)
	
remotesync func _take_damage(damage :int, hp_remain :int) -> void:
	hp = hp_remain
	emit_signal("building_take_damage", self, damage)
	
func _disable_process():
	set_process(false)
	
	if _is_master and is_instance_valid(_network_timmer):
		_network_timmer.stop()
		_network_timmer.queue_free()
		
	
func _building_timmer_timeout():
	if not _is_master:
		return
		
	rpc("_finish_building")
	
func get_build_progress() -> float:
	return _building_timmer.time_left
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	translation = translation.linear_interpolate(_puppet_translation, 5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)

func take_damage(damage :int) -> void:
	if is_dead:
		return
		
	hp -= (damage / 2)
	if hp < 1:
		is_dead = true
		rpc("_dead")
		return
		
	rpc_unreliable("_take_damage", damage, hp)
	
	
func demolish() -> void:
	rpc("_dead")
	
remotesync func _dead() -> void:
	set_process(false)
	is_dead = true
	emit_signal("building_destroyed", self)
