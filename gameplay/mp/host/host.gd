extends BaseGameplay

const squads = [
	#preload("res://data/squad_data/squads/archer_squad.tres"),
	preload("res://data/squad_data/squads/axeman_squad.tres"),
	preload("res://data/squad_data/squads/militia_squad.tres"),
	preload("res://data/squad_data/squads/spearman_squad.tres"),
	preload("res://data/squad_data/squads/swordman_squad.tres"),
]

var selected_squad :Squad
onready var squad_holder = $squad_holder

var team :int = 1
var pos :int = 0
onready var positions = [$Position1, $Position2, $Position3, $Position4]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)
	
	if not is_instance_valid(selected_squad):
		return
		
	selected_squad.is_moving = true
	selected_squad.move_to = _pos
	
	_tap.translation = _pos
	_tap.tap()

func on_squad_selected(_squad :Squad):
	.on_squad_selected(_squad)
	
	if is_instance_valid(selected_squad):
		selected_squad.set_selected(false)
		
	selected_squad = _squad
	selected_squad.set_selected(true)

func _on_Timer_timeout():
	if team > 4:
		return
	
	var squad = squads[rand_range(0, squads.size())]
	squad.node_name = GDUUID.v4()
	squad.network_master = Network.PLAYER_HOST_ID
	squad.color = Color(randf(),randf(),randf(), 1.0)
	squad.team = team
	spawn_squad(
		squad, squad_holder.get_path(),
		positions[pos].translation
	)
	
	pos = pos + 1 if pos < positions.size() - 1 else 0
	team += 1
