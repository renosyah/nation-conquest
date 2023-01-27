extends "res://entity/unit/unit_scripts/melee_infantry.gd"

export var shield_hp :int = 100

func take_damage(damage :int) -> void:
	if is_dead:
		return
		
	if shield_hp < 0:
		.take_damage(damage)
		return
		
	shield_hp -= damage
