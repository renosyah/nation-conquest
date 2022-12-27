extends BaseGameplay

const units = [
	preload("res://entity/unit/axeman/axeman.tscn"),
	preload("res://entity/unit/militia/militia.tscn"),
	preload("res://entity/unit/swordman/swordman.tscn"),
	preload("res://entity/unit/spearman/spearman.tscn")
]

var squad
onready var node = $Node

var is_left = false
var team = 1

onready var positions_1 = $Position3D.translation
onready var positions_2 = $Position3D2.translation

func on_map_click(_pos :Vector3):
	if not is_instance_valid(squad):
		return
		
	squad.is_moving = true
	squad.move_to = _pos

func _on_squad_selected(_squad):
	squad = _squad

func _on_Timer_timeout():
	if node.get_child_count() > 1:
		return
		
	is_left = not is_left
	team += 1
	
	var spawn = preload("res://entity/squad/squad.tscn").instance()
	spawn.unit = units[rand_range(0, units.size())]
	spawn.color = Color(randf(),randf(),randf(), 1.0)
	spawn.team = team
	spawn.connect("squad_selected", self,"_on_squad_selected")
	spawn.translation = positions_1 if is_left else positions_2
	node.add_child(spawn)

