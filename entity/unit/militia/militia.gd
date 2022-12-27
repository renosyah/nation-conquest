extends BaseUnit

onready var pivot = $pivot
onready var body = $body
onready var animation_weapon_state = $pivot/AnimationTree.get("parameters/playback")
onready var animation_body_state = $AnimationTree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	body.modulate = color
	
func perform_attack():
	.perform_attack()
	animation_weapon_state.travel("swing")
	
func idle(delta :float):
	.idle(delta)
	
	var origin = pivot.global_transform.origin
	var dir = _direction * 100
	dir.y = 0
	
	if dir.length() < 5.0:
		return
	
	var _transform = pivot.transform.looking_at(dir, Vector3.UP)
	pivot.transform = pivot.transform.interpolate_with(_transform, 5 * delta)
	
	if is_moving or is_attacking:
		animation_body_state.travel("moving")
	else:
		animation_body_state.travel("idle")

