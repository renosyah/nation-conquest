extends BaseGameplay

onready var player_team :int = 1
onready var player_color :Color = Color(randf(), randf(), randf(), 1)
onready var squad_spawn_position :Vector3 = Vector3(0, 15, 0)
onready var taps = $taps

var bots :Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)
	
	taps.color = player_color
	taps.taps(_selected_squad)
	
func on_generate_map_completed():
	.on_generate_map_completed()
	
	var player_id :int = NetworkLobbyManager.get_id()
	player_color = _player_color[player_id]
	squad_spawn_position = _player_base_spawn_position[player_id]
	_camera.translation = squad_spawn_position
	
	NetworkLobbyManager.set_host_ready()
	
func on_ui_recruit_squad(_squad :SquadData):
	.on_ui_recruit_squad(_squad)
	
	_squad.player_id = NetworkLobbyManager.get_id()
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = player_color
	_squad.team = player_team
	_squad.position = squad_spawn_position + Vector3(0, _map.map_height, 0)
	
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
	
################################################################
# bot & game
func all_player_ready():
	.all_player_ready()
	
	var bot_spawn_positions :Array = _map.base_spawn_positions.slice(0, 3)
	var bot_count :int = bot_spawn_positions.size()
	
	# deploy player town center
	for player in NetworkLobbyManager.get_players():
		var base_spawn_position :Vector3 = _player_base_spawn_position[player.player_network_unique_id]
		var town_center :BuildingData = preload("res://data/building_data/buildings/town_center.tres")
		town_center.player_id = player.player_network_unique_id
		town_center.node_name = GDUUID.v4()
		town_center.network_master = player.player_network_unique_id
		town_center.color = _player_color[player.player_network_unique_id]
		town_center.team = player_team
		
		.on_deploying_building(town_center, base_spawn_position, true)
		
		bot_count -= 1
		bot_spawn_positions.erase(base_spawn_position)
		
		
	for i in range(bot_count):
		var base_spawn_position :Vector3 = bot_spawn_positions[i]
		var bot :MPBot = preload("res://gameplay/mp/util/bot/mp_bot.tscn").instance()
		bot.bot_id = -i + 69
		bot.bot_color = Color(randf(), randf(), randf(), 1)
		bot.bot_team = i + 69
		bot.connect("bot_recruit_squad", self, "on_bot_recruit_squad")
		bot.connect("bot_deploying_building", self, "on_bot_deploying_building")
		add_child(bot)
		bots[bot.bot_id] = bot
		
		.on_deploying_building(bot.get_town_center_data(), base_spawn_position, true)
		
		
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
		
# bot deploy squad
func on_bot_recruit_squad(_mp_bot :MPBot, _squad_data :SquadData):
	.spawn_squad(_squad_data)
	
# bot deploy building
func on_bot_deploying_building(_mp_bot :MPBot, _building_data :BuildingData):
	.on_deploying_building(_building_data)
	
# bot using auto builder
func on_building_deplyoing(_building :BaseBuilding):
	if bots.has(_building.player_id):
		bots[_building.player_id].start_find_placement(
			_building, _all_squads + _buildings, [_water]
		)
		return
		
	# continue, because if else 
	# is player is currenlty building
	.on_building_deplyoing(_building)












