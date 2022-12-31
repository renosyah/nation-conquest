extends BaseUnit

const hit_sounds :Array = [preload("res://assets/sound/fight1.wav"), preload("res://assets/sound/fight2.wav"), preload("res://assets/sound/fight3.wav"), preload("res://assets/sound/fight4.wav"), preload("res://assets/sound/fight5.wav")]
const dead_sound :Array = [preload("res://assets/sound/maledeath1.wav"), preload("res://assets/sound/maledeath2.wav"), preload("res://assets/sound/maledeath3.wav"), preload("res://assets/sound/maledeath4.wav")]

var attack_animation :String
onready var pivot = $pivot
onready var body = $body
onready var animation_weapon_state = $pivot/AnimationTree.get("parameters/playback")
onready var animation_body_state = $AnimationTree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	attack_animation = "swing"
	body.modulate = color
	
func perform_attack():
	.perform_attack()
	animation_weapon_state.travel(attack_animation)
	
	if _sound.playing:
		return
	
	_sound.stream = hit_sounds[rand_range(0, hit_sounds.size())]
	_sound.play()
	
func dead() -> void:
	if _sound.playing:
		_sound.stop()
		
	_sound.stream = dead_sound[rand_range(0, dead_sound.size())]
	_sound.play()
	
	yield(_sound, "finished")
	
	.dead()
	
func attacking(delta :float):
	.attacking(delta)
	
	if not is_attacking:
		return
		
	if not is_instance_valid(attack_to):
		return
		
	var enemy_pos :Vector3 = attack_to.global_transform.origin
	var pos = global_transform.origin
	var to = Vector3(enemy_pos.x, pos.y, enemy_pos.z)
	var dis = pos.distance_squared_to(to)
	if dis < 10.0:
		return
		
	var _transform = pivot.transform.looking_at(pos.direction_to(to) * 100, Vector3.UP)
	pivot.transform = pivot.transform.interpolate_with(_transform, 5 * delta)
	
func moving(delta :float):
	.moving(delta)
	
	if _direction == Vector3.ZERO:
		return
		
	var _transform = pivot.transform.looking_at(_direction * 100, Vector3.UP)
	pivot.transform = pivot.transform.interpolate_with(_transform, 5 * delta)
	
func idle(delta :float):
	.idle(delta)
	
	var dir = Vector3(_velocity.x, 0, _velocity.z)
	if dir == Vector3.ZERO:
		animation_body_state.travel("idle")
		return
		
	animation_body_state.travel("moving")
