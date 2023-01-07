extends BaseGameplay

onready var selected_squad :Array = []
onready var player_squad_holder = $player_squad_holder
onready var color :Color = Color(randf(), randf(), randf(), 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func all_player_ready():
	.all_player_ready()
	
func _on_ui_recruit_squad(_squad :SquadData, _icon :Resource):
	._on_ui_recruit_squad(_squad, _icon)
	
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = color
	_squad.team = 1
	_squad.icon = _icon
	
	spawn_squad(
		_squad, player_squad_holder.get_path(),
		_spawn_points[4] + Vector3(0, 15, 0)
	)
	
func _on_ui_deploy_building(_building_data :BuildingData):
	._on_ui_deploy_building(_building_data)
	
	_building_data.color = color
	_building_data.node_name = GDUUID.v4()
	_building_data.team = 1
	_building_data.network_master = NetworkLobbyManager.get_id()
	
	on_deploying_building(_building_data)
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)
	
	if selected_squad.empty():
		return
	
	var formation = Utils.get_formation_box(
		_pos, selected_squad.size(), 5
	)
	for i in range(selected_squad.size()):
		if is_instance_valid(selected_squad[i]):
			selected_squad[i].set_move_to(formation[i], true)
	
func on_squad_selected(_squad :Squad):
	.on_squad_selected(_squad)
	
	if _squad.get_network_master() != NetworkLobbyManager.get_id():
		return
		
	var is_in_squad = selected_squad.has(_squad)
	if is_in_squad:
		_squad.set_selected(false)
		_ui.on_squad_selected(_squad, false)
		selected_squad.erase(_squad)
	else:
		_squad.set_selected(true)
		_ui.on_squad_selected(_squad, true)
		selected_squad.append(_squad)
		
func on_squad_dead(_squad :Squad):
	if selected_squad.has(_squad):
		selected_squad.erase(_squad)
		
	.on_squad_dead(_squad)
