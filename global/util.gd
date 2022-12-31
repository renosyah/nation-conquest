extends Node
class_name Utils

static func get_formation_box(pos :Vector3, max_unit :int, formation_space :int) -> Array:
	if max_unit <= 1:
		return [pos]
		
	var formations = []
	var s_side = round(sqrt(max_unit))
	var unit_pos = pos - formation_space * Vector3(s_side/2,pos.y, s_side/2)
	
	for i in max_unit:
		unit_pos.y = pos.y
		formations.append(unit_pos)
		unit_pos.x += formation_space
		if unit_pos.x > (pos.x + s_side * formation_space / 2):
			unit_pos.z += formation_space
			unit_pos.x = pos.x - formation_space * s_side / 2
			
	return formations
	
static func get_formation_circle(pos :Vector3, max_unit :int, formation_space :int) -> Array:
	if max_unit <= 1:
		return [pos]
		
	var formations = []
	var unit_pos = pos
	var circle_size = 0
	var unit_total_count_in_circle = 6 * circle_size
	var unit_count_in_circle = 0
	var current_angle = 0
	
	for x in max_unit:
		formations.append(unit_pos)
		unit_count_in_circle += 1
		if unit_count_in_circle >= unit_total_count_in_circle:
			unit_count_in_circle = 0
			current_angle = 0
			circle_size += 1
			unit_total_count_in_circle = 6 * circle_size
			unit_pos.x = pos.x + formation_space * circle_size
			unit_pos.z = pos.z
		else:
			current_angle += (PI/3) / circle_size
			unit_pos.x = pos.x + (formation_space * circle_size) * cos(current_angle)
			unit_pos.z = pos.z + (formation_space * circle_size) * sin(current_angle)
			
	return formations
