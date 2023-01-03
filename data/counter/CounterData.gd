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
		
		# check round arround counter
		if unit_role == 0 and role_to_counter == 3:
			unit_role = 4
			
		elif role_to_counter == 0 and unit_role == 3:
			role_to_counter = 4
		
		if unit_role + 1 == role_to_counter:
			# lose 50 % bonus damage
			bonus -= int(current_damage * 0.50)
			
		elif unit_role - 1 == role_to_counter:
			# got 50 % bonus damage
			bonus += int(current_damage * 0.50)
		
	# current tier is lower
	else:
		# lose 25 % bonus damage
		bonus = bonus - int(current_damage * 0.25)
		
		# check round arround counter
		if unit_role == 0 and role_to_counter == 3:
			unit_role = 4
			
		elif role_to_counter == 0 and unit_role == 3:
			role_to_counter = 4
		
		if unit_role + 1 == role_to_counter:
			# lose 50 % bonus damage
			bonus -= int(current_damage * 0.50)
			
		elif unit_role - 1 == role_to_counter:
			# got 50 % bonus damage
			bonus += int(current_damage * 0.50)
			
	var final_damage :int = current_damage + bonus
	return final_damage if final_damage > 0 else 1
