extends BaseGameplay

onready var player_team :int = Global.player.player_team
onready var player_color :Color = Global.player.player_color
onready var squad_spawn_position :Vector3 = Vector3(0, 15, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	_ui.player_team = player_team
	
func on_generate_map_completed():
	.on_generate_map_completed()
	
	var player_id :int = NetworkLobbyManager.get_id()
	player_color = _player_color[player_id]
	squad_spawn_position = _player_base_spawn_position[player_id]
	_camera.translation = squad_spawn_position
	
func on_ui_recruit_squad(_squad :SquadData):
	.on_ui_recruit_squad(_squad)
	
	_squad.player_id = NetworkLobbyManager.get_id()
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = player_color
	_squad.team = player_team
	_squad.position = squad_spawn_position + Vector3(0, 5, 0)
	
	.spawn_squad(_squad)
	
func on_ui_deploy_building(_building_data :BuildingData):
	.on_ui_deploy_building(_building_data)
	
	_building_data.player_id = NetworkLobbyManager.get_id()
	_building_data.node_name = GDUUID.v4()
	_building_data.network_master = NetworkLobbyManager.get_id()
	_building_data.color = player_color
	_building_data.team = player_team
	_building_data.base_position = squad_spawn_position
	_building_data.max_distance_from_base = 24
	
	.on_deploying_building(_building_data)
	
func on_building_destroyed(_building :BaseBuilding):
	.on_building_destroyed(_building)
	
	if not _building is TownCenter:
		return
		
	if _ui.is_player_building(_building):
		_ui.on_player_lose()
		
func on_team_wining(_team:int):
	.on_team_wining(_team)
	
	if _team == player_team:
		_ui.on_player_win()
