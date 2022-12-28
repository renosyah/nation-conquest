extends BaseGameplay

const units = [
	preload("res://entity/unit/axeman/axeman.tscn"),
	preload("res://entity/unit/militia/militia.tscn"),
	preload("res://entity/unit/swordman/swordman.tscn"),
	preload("res://entity/unit/spearman/spearman.tscn")
]

var squad
onready var node = $Node

var team :int = 1
var pos :int = 0
onready var positions = [$Position1, $Position2, $Position3, $Position4]

func on_map_click(_pos :Vector3):
	if not is_instance_valid(squad):
		return
		
	squad.is_moving = true
	squad.move_to = _pos

func _on_squad_selected(_squad):
	squad = _squad

func _on_Timer_timeout():
	if node.get_child_count() > 3:
		return
		
	var spawn = preload("res://entity/squad/squad.tscn").instance()
	spawn.unit = units[rand_range(0, units.size())]
	spawn.color = Color(randf(),randf(),randf(), 1.0)
	spawn.team = team
	spawn.connect("squad_selected", self,"_on_squad_selected")
	spawn.translation = positions[pos].translation
	node.add_child(spawn)
	spawn.is_moving = true
	spawn.move_to = get_rand_pos($Position5.translation)
	
	_ui.mini_map.add_object(spawn.get_path(), spawn.color)
	
	pos = pos + 1 if pos < positions.size() - 1 else 0
	team += 1
	
func get_rand_pos(from :Vector3) -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(3, 4)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = from + Vector3(posv2.x, 4.0, posv2.y)
	return posv3
