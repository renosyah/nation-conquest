extends BaseUnit

const hit_sounds :Array = [preload("res://assets/sound/fight1.wav"), preload("res://assets/sound/fight2.wav"), preload("res://assets/sound/fight3.wav"), preload("res://assets/sound/fight4.wav"), preload("res://assets/sound/fight5.wav")]
const dead_sound :Array = [preload("res://assets/sound/maledeath1.wav"), preload("res://assets/sound/maledeath2.wav"), preload("res://assets/sound/maledeath3.wav"), preload("res://assets/sound/maledeath4.wav")]

var attack_animation :String
onready var pivot = $pivot
onready var horse_pivot = $body/horse_pivot

onready var body = $body/body2

onready var animation_weapon_state = $pivot/AnimationTree.get("parameters/playback")
onready var animation_body_state = $AnimationTree.get("parameters/playback")

var _combat_anim_delay_timmer :Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	_combat_anim_delay_timmer = Timer.new()
	_combat_anim_delay_timmer.wait_time = 1
	_combat_anim_delay_timmer.autostart = false
	_combat_anim_delay_timmer.one_shot = true
	add_child(_combat_anim_delay_timmer)
	
	attack_animation = "swing"
	body.modulate = color
	
func in_combat(is_arrive :bool):
	.in_combat(is_arrive)
	
	if is_arrive and _combat_anim_delay_timmer.is_stopped():
		animation_weapon_state.travel(attack_animation)
		
		if not _sound.playing and visible:
			_sound.stream = hit_sounds[rand_range(0, hit_sounds.size())]
			_sound.play()
			
		_combat_anim_delay_timmer.start()
		
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
	._turn_spatial_pivot_to_attack(horse_pivot, delta)
	
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
	
func _move_to_position(_at :Vector3, _margin :float) -> bool:
	# full override dont uncomment
	#._move_to_position(_at, _margin)
	
	var pos :Vector3 = global_transform.origin
	var to :Vector3 = Vector3(_at.x , pos.y, _at.z)
	var distance :float = pos.distance_to(to)
	if distance <= _margin:
		return true
	
	var _speed_modifer :float = float(speed * distance) if is_moving else float(speed)

	_direction = translation.direction_to(to)
	_velocity = _direction * _speed_modifer
	_velocity.y = 0
	
	return false

