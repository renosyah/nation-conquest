extends Node
class_name CounterData

#	-> : get counter by
#
#	tier counter : 0, 1, 2
#	axeman -> maceman -> sentinel (shock infantry)
#	archer -> crossbowman -> longbowman (range)
#	spearman -> pikeman -> halberdier (spear infantry)
#	militia -> swordman -> knight (sword infantry)
#
#	role counter : 
#	(sword infantry) : 0 -> (spear infantry) : 1 -> (range) : 2 ->  (shock infantry) : 3

export var unit_tier :int
export var unit_role :int

func get_attack_modifier(tier_to_counter :int, role_to_counter :int, current_damage :int) -> int:
	var bonus = 0
	
	# current tier is higher
	if unit_tier > tier_to_counter:
		# got 25 % bonus damage
		bonus += int(current_damage * 0.25)
		bonus += _get_attack_modifier_by_role(
			tier_to_counter, role_to_counter, current_damage
		)
		
	# current tier is lower
	elif unit_tier < tier_to_counter:
		
		# lose 25 % bonus damage
		bonus -= int(current_damage * 0.25)
		bonus += _get_attack_modifier_by_role(
			tier_to_counter, role_to_counter, current_damage
		)
		
	# current tier same
	else:
		bonus += _get_attack_modifier_by_role(
			tier_to_counter, role_to_counter, current_damage
		)
		
	var final_damage :int = current_damage + bonus
	return final_damage if final_damage > 0 else 1

func _get_attack_modifier_by_role(tier_to_counter :int, role_to_counter :int, current_damage :int) -> int:
	var _bonus = 0
	var _unit_role = unit_role
	var _role_to_counter = role_to_counter
	
	# check round arround counter
	if unit_role == 0 and role_to_counter == 3:
		_unit_role = 4
		
	elif role_to_counter == 0 and unit_role == 3:
		_role_to_counter = 4
	
	if _unit_role + 1 == _role_to_counter:
		# lose 50 % bonus damage
		_bonus -= int(current_damage * 0.50)
		
	elif _unit_role - 1 == _role_to_counter:
		# got 50 % bonus damage
		_bonus += int(current_damage * 0.50)
		
	return _bonus
