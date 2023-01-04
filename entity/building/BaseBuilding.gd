extends BaseEntity
class_name BaseBuilding

signal building_take_damage(_building, _damage)
signal building_destroyed(_building)

const status_deploying = 0
const status_building = 1
const status_deployed = 2

export var team :int = 0
export var color :Color = Color.white

export var hp :int = 500
export var max_hp :int = 500

export var building_time :int = 10

export var is_dead :bool = false
export var status :int = status_deploying

puppet var _puppet_translation :Vector3
puppet var _puppet_rotation :Vector3

############################################################
# multiplayer func
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if is_dead:
		return
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
		
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
		
	hp -= damage
	if hp < 1:
		set_process(false)
		is_dead = true
		dead()
		return
		
	emit_signal("building_take_damage", self, damage)
	
func dead() -> void:
	emit_signal("building_destroyed", self)

