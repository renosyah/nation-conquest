extends BaseGameplay

const squads = [
	preload("res://data/squad_data/squads/pikeman_squad.tres"),
	preload("res://data/squad_data/squads/maceman_squad.tres"),
	preload("res://data/squad_data/squads/crossbowman_squad.tres"),
	preload("res://data/squad_data/squads/archer_squad.tres"),
	preload("res://data/squad_data/squads/axeman_squad.tres"),
	preload("res://data/squad_data/squads/militia_squad.tres"),
	preload("res://data/squad_data/squads/spearman_squad.tres"),
	preload("res://data/squad_data/squads/swordman_squad.tres"),
]

var selected_squad :Array = []

var pos :int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)
	
	if selected_squad.empty():
		return
	
	var formation = Utils.get_formation_box(
		_pos, selected_squad.size(), 5
	)
	for i in range(selected_squad.size()):
		if is_instance_valid(selected_squad[i]):
			selected_squad[i].set_selected(false)
			selected_squad[i].set_move_to(formation[i])
			
	selected_squad.clear()
	
func on_squad_selected(_squad :Squad):
	.on_squad_selected(_squad)
	
	var is_in_squad = selected_squad.has(_squad)
	_squad.set_selected(not is_in_squad)
	
	if is_in_squad:
		selected_squad.erase(_squad)
	else:
		selected_squad.append(_squad)
		
func on_squad_dead(_squad :Squad):
	if selected_squad.has(_squad):
		selected_squad.erase(_squad)
		
	.on_squad_dead(_squad)
	
func _on_Timer_timeout():
	if $squad_holder.get_child_count() > 6:
		return
		
	var positions = [$Position1, $Position2, $Position3, $Position4]
	var colors = [Color.red, Color.blue, Color.green, Color.yellow]
	var squad = squads[rand_range(0, squads.size())]
	squad.node_name = GDUUID.v4()
	squad.network_master = Network.PLAYER_HOST_ID
	squad.color = colors[pos]
	squad.team = pos
	spawn_squad(
		squad, $squad_holder.get_path(),
		positions[pos].translation
	)
	
	pos = pos + 1 if pos < positions.size() - 1 else 0
