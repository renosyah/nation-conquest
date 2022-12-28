extends BaseUnit

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
	
func take_damage(damage :int) -> void:
	.take_damage(damage)
	
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
	
	
func idle(delta :float):
	.idle(delta)
	
	var origin = pivot.global_transform.origin
	var dir = Vector3(_velocity.x, 0, _velocity.z)
	
	if clamp(dir.length(), 0.0, 1.0) < 1.0:
		animation_body_state.travel("idle")
		return
		
	animation_body_state.travel("moving")
	
	var _transform = pivot.transform.looking_at(_direction * 100, Vector3.UP)
	pivot.transform = pivot.transform.interpolate_with(_transform, 5 * delta)

