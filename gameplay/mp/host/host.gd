extends BaseGameplay

var squad

onready var squad_1 = $squad
onready var squad_2 = $squad2

func on_map_click(_pos :Vector3):
	if not squad:
		return
		
	squad.is_moving = true
	squad.move_to = _pos

func _on_squad_selected(_squad):
	squad = _squad
