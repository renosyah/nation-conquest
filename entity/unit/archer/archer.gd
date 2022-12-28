extends BaseUnit

const arrow_projectile = preload("res://entity/projectile/arrow/arrow.tscn")

const hit_sounds :Array = [preload("res://assets/sound/stab1.wav"), preload("res://assets/sound/stab2.wav")]
const dead_sound :Array = [preload("res://assets/sound/maledeath1.wav"), preload("res://assets/sound/maledeath2.wav"), preload("res://assets/sound/maledeath3.wav"), preload("res://assets/sound/maledeath4.wav")]

var attack_animation :String
onready var pivot = $pivot
onready var body = $body
onready var animation_weapon_state = $pivot/AnimationTree.get("parameters/playback")
onready var animation_body_state = $AnimationTree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	attack_animation = "shot"
	body.modulate = color
	
func perform_attack():
	animation_weapon_state.travel(attack_animation)
	
	if not is_instance_valid(attack_to):
		return
		
	var arrow = arrow_projectile.instance()
	arrow.target = attack_to.global_transform.origin
	arrow.connect("hit", self ,"_arrow_hit")
	add_child(arrow)
		
func _arrow_hit():
	.perform_attack()
	
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
	var at = Vector3(enemy_pos.x, pos.y, enemy_pos.z)
	var dir = pos.direction_to(at)
	
	var _transform = pivot.transform.looking_at(dir * 100, Vector3.UP)
	pivot.transform = pivot.transform.interpolate_with(_transform, 5 * delta)
	
func moving(delta :float):
	.moving(delta)
	
	if not is_moving:
		return
		
	var _transform = pivot.transform.looking_at(_direction * 100, Vector3.UP)
	pivot.transform = pivot.transform.interpolate_with(_transform, 5 * delta)
	
func idle(delta :float):
	.idle(delta)
	
	if clamp(_direction.length_squared(), 0.0, 1.0) < 1.0:
		animation_body_state.travel("idle")
		return
		
	animation_body_state.travel("moving")
