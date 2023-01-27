extends "res://entity/unit/unit_scripts/melee_infantry.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	attack_animation = "trush"
	body.modulate = color
	
func attacking(delta :float):
	.attacking(delta)
	
	if not is_attacking:
		animation_weapon_state.travel("idle")
		return
