extends BaseGameplay

onready var color :Color = Color(randf(), randf(), randf(), 1)
onready var squad_spawn_position :Vector3 = Vector3(0, 15, 0)

var player_team :int = 1
var bots :Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func on_generate_map_completed():
	.on_generate_map_completed()
	
	squad_spawn_position = _player_base_spawn_position[NetworkLobbyManager.get_id()]
	_camera.translation = squad_spawn_position
	
	NetworkLobbyManager.set_host_ready()
	
func on_ui_recruit_squad(_squad :SquadData):
	.on_ui_recruit_squad(_squad)
	
	_squad.player_id = NetworkLobbyManager.get_id()
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = color
	_squad.team = player_team
	_squad.position = squad_spawn_position + Vector3(0, _map.map_height, 0)
	
	.spawn_squad(_squad)
	
func on_ui_deploy_building(_building_data :BuildingData):
	.on_ui_deploy_building(_building_data)
	
	_building_data.player_id = NetworkLobbyManager.get_id()
	_building_data.node_name = GDUUID.v4()
	_building_data.network_master = NetworkLobbyManager.get_id()
	_building_data.color = color
	_building_data.team = player_team
	_building_data.base_position = squad_spawn_position
	_building_data.max_distance_from_base = 24
	
	.on_deploying_building(_building_data)
	
################################################################
# bot & game
func all_player_ready():
	.all_player_ready()
	
	var bot_count :int = 4
	var bot_spawn_positions :Array = _map.base_spawn_positions.duplicate()
	
	# deploy player town center
	for player in NetworkLobbyManager.get_players():
		var base_spawn_position :Vector3 = _player_base_spawn_position[player.player_network_unique_id]
		var town_center :BuildingData = preload("res://data/building_data/buildings/town_center.tres")
		town_center.player_id = player.player_network_unique_id
		town_center.node_name = GDUUID.v4()
		town_center.network_master = player.player_network_unique_id
		town_center.color = color
		town_center.team = 1
		
		.on_deploying_building(town_center, base_spawn_position, true)
		
		bot_count -= 1
		bot_spawn_positions.erase(base_spawn_position)
		
		
	for i in range(bot_count):
		var bot :MPBot = preload("res://gameplay/mp/util/mp_bot.tscn").instance()
		bot.bot_id = -i + 69
		bot.bot_color = Color(randf(), randf(), randf(), 1)
		bot.bot_team = i + 69
		bot.connect("bot_recruit_squad", self, "on_bot_recruit_squad")
		bot.connect("bot_deploying_building", self, "on_bot_deploying_building")
		add_child(bot)
		bots[bot.bot_id] = bot
		
		.on_deploying_building(bot.get_town_center_data(), bot_spawn_positions[i], true)
		
		
func on_squad_spawn(_squad :Squad, _icon :Resource):
	.on_squad_spawn(_squad, _icon)
	
	for key in bots.keys():
		bots[key].on_squad_spawn(_squad)
	
func on_squad_dead(_squad :Squad):
	.on_squad_dead(_squad)
	
	for key in bots.keys():
		bots[key].on_squad_dead(_squad)
		
func on_building_deployed(_building :BaseBuilding):
	.on_building_deployed(_building)
	
	for key in bots.keys():
		bots[key].on_building_deployed(_building)
		
func on_building_destroyed(_building :BaseBuilding):
	.on_building_destroyed(_building)
	
	for key in bots.keys():
		bots[key].on_building_destroyed(_building)
		
		
func on_bot_recruit_squad(_mp_bot :MPBot, _squad_data :SquadData):
	
	# bot deploy squad
	.spawn_squad(_squad_data)
	
func on_bot_deploying_building(_mp_bot :MPBot, _building_data :BuildingData):
	
	# bot deploy building
	.on_deploying_building(_building_data)

func on_building_deplyoing(_building :BaseBuilding):
	
	# bot using auto builder
	if bots.has(_building.player_id):
		var ignores :Array = _all_squads + _buildings
		bots[_building.player_id].start_find_placement(_building, ignores)
		return
		
	# continue, because if else 
	# is player is currenlty building
	.on_building_deplyoing(_building)












