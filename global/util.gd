extends Node
class_name Utils

const COLORS = [
	"#800000",
	"#8B0000",
	"#B22222",
	"#FF0000",
	"#FA8072",
	"#FF6347",
	"#FF7F50",
	"#FF4500",
	"#D2691E",
	"#F4A460",
	"#FF8C00",
	"#FFA500",
	"#B8860B",
	"#DAA520",
	"#FFD700",
	"#808000",
	"#FFFF00",
	"#9ACD32",
	"#ADFF2F",
	"#7FFF00",
	"#7CFC00",
	"#008000",
	"#00FF00",
	"#32CD32",
	"#00FF7F",
	"#00FA9A",
	"#40E0D0",
	"#20B2AA",
	"#48D1CC",
	"#008B8B",
	"#00FFFF",
	"#00CED1",
	"#00BFFF",
	"#1E90FF",
	"#4169E1",
	"#00BFFF",
	"#1E90FF",
	"#4169E1",
	"#000080",
	"#00008B",
	"#0000CD",
	"#0000FF",
	"#8A2BE2",
	"#9932CC",
	"#9400D3",
	"#800080",
	"#8B008B",
]

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
