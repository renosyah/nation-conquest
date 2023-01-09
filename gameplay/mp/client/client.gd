extends BaseGameplay

onready var color :Color = Color(randf(), randf(), randf(), 1)
onready var player_squad_holder = $player_squad_holder

var squad_spawn_position :Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func on_generate_map_completed():
	.on_generate_map_completed()
	squad_spawn_position = _base_spawn_points[4]
	_camera.translation = squad_spawn_position
	
func on_ui_recruit_squad(_squad :SquadData):
	.on_ui_recruit_squad(_squad)
	
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = color
	_squad.team = 1
	
	.spawn_squad(_squad, Vector3(0, 15, 0), player_squad_holder.get_path())
	
func on_ui_deploy_building(_building_data :BuildingData):
	.on_ui_deploy_building(_building_data)
	
	_building_data.node_name = GDUUID.v4()
	_building_data.color = color
	_building_data.team = 1
	_building_data.network_master = NetworkLobbyManager.get_id()
	
	.on_deploying_building(_building_data)
