extends BaseUnit

const arrow_projectile = preload("res://entity/projectile/arrow/arrow.tscn")

const hit_sounds :Array = [preload("res://assets/sound/stab1.wav"), preload("res://assets/sound/stab2.wav")]
const dead_sound :Array = [preload("res://assets/sound/maledeath1.wav"), preload("res://assets/sound/maledeath2.wav"), preload("res://assets/sound/maledeath3.wav"), preload("res://assets/sound/maledeath4.wav")]

var attack_animation :String
onready var pivot = $pivot
onready var horse_pivot = $body/horse_pivot

onready var body = $body/body2

onready var animation_weapon_state = $pivot/AnimationTree.get("parameters/playback")
onready var animation_body_state = $AnimationTree.get("parameters/playback")

var _arrows_pool :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	attack_animation = "shot"
	body.modulate = color
	_create_arrow_pools()
	
func _create_arrow_pools():
	for i in range(4):
		_arrows_pool.append(_create_arrow())
	
func _get_arrow() -> BaseProjectile:
	for arrow in _arrows_pool:
		if not arrow.visible:
			return arrow
			
	var arrow = _create_arrow()
	_arrows_pool.append(arrow)
	return arrow
	
func _create_arrow() -> BaseProjectile:
	var arrow = arrow_projectile.instance()
	arrow.speed = 12
	arrow.connect("hit", self ,"_arrow_hit", [arrow])
	
	var last_index = get_tree().get_root().get_child_count() - 1
	get_tree().get_root().get_child(last_index).add_child(arrow)
	return arrow
	
func perform_attack():
	animation_weapon_state.travel(attack_animation)
	
func _on_animation_projectile_release():
	if not is_instance_valid(attack_to):
		return
		
	var arrow = _get_arrow()
	arrow.translation = global_transform.origin
	arrow.accuration = skill
	
	if attack_to.has_method("get_prediction_path"):
		arrow.target = attack_to.get_prediction_path()
	else:
		arrow.target = attack_to.global_transform.origin
		
	arrow.fire()
	
func _arrow_hit(_arrow :BaseProjectile):
	if not _sound.playing and visible:
		_sound.stream = hit_sounds[rand_range(0, hit_sounds.size())]
		_sound.play()
		
	if not is_instance_valid(attack_to):
		return
		
	var _target_pos :Vector3 = attack_to.global_transform.origin * Vector3(1,0,1)
	var _projectile_pos :Vector3 = _arrow.global_transform.origin * Vector3(1,0,1)
	
	if _projectile_pos.distance_squared_to(_target_pos) > 10:
		return
		
	.perform_attack()
	
func dead() -> void:
	if visible:
		if _sound.playing:
			_sound.stop()
			
		_sound.stream = dead_sound[rand_range(0, dead_sound.size())]
		_sound.play()
		
		visible = false
		
		yield(_sound, "finished")
		
	.dead()
	
func attacking(delta :float):
	.attacking(delta)
	
	._turn_spatial_pivot_to_attack(pivot, delta)
	
func moving(delta :float):
	.moving(delta)
	
	._turn_spatial_pivot_to_moving(pivot, delta)
	._turn_spatial_pivot_to_moving(horse_pivot, delta)
	
func idle(delta :float):
	.idle(delta)
	
	var dir :Vector3 = _velocity * Vector3(1, 0, 1)
	if dir == Vector3.ZERO:
		animation_body_state.travel("idle")
		return
		
	animation_body_state.travel("moving")
	
func _on_archer_cavalry_tree_exiting():
	for i in _arrows_pool:
		i.queue_free()

