extends BaseGameplay

onready var player_data :PlayerData = PlayerData.new()
onready var squad_spawn_position :Vector3 = Vector3(0, 15, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	player_data.from_dictionary(NetworkLobbyManager.player_extra_data)
	_ui.player_team = player_data.player_team
	
func on_generate_map_completed():
	.on_generate_map_completed()
	
	squad_spawn_position = _player_base_spawn_position[NetworkLobbyManager.get_id()]
	_camera.translation = squad_spawn_position
	
func on_ui_recruit_squad(_squad :SquadData):
	.on_ui_recruit_squad(_squad)
	
	_squad.player_id = NetworkLobbyManager.get_id()
	_squad.player_name = player_data.player_name
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = player_data.player_color
	_squad.team = player_data.player_team
	_squad.position = squad_spawn_position + Vector3(0, 5, 0)
	
	.spawn_squad(_squad)
	
func on_ui_deploy_building(_building_data :BuildingData):
	.on_ui_deploy_building(_building_data)
	
	_building_data.player_id = NetworkLobbyManager.get_id()
	_building_data.node_name = GDUUID.v4()
	_building_data.network_master = NetworkLobbyManager.get_id()
	_building_data.color = player_data.player_color
	_building_data.team = player_data.player_team
	_building_data.base_position = squad_spawn_position
	
	.on_deploying_building(_building_data)
	
func on_building_destroyed(_building :BaseBuilding):
	.on_building_destroyed(_building)
	
	if not _building is TownCenter:
		return
		
	if not _ui.is_player_building(_building):
		return
		
	_ui.on_player_lose()
	
func on_capture_point_score(_capture_point :CapturePoint, _amount :int):
	.on_capture_point_score(_capture_point, _amount)
	
	if _capture_point.team == player_data.player_team:
		_ui.on_capture_point_score(_capture_point, _amount)
	
func on_team_wining(_team:int):
	.on_team_wining(_team)
	
	if _team == player_data.player_team:
		_ui.on_player_win()
