extends BaseGameplay

onready var color :Color = Color(randf(), randf(), randf(), 1)
onready var squad_spawn_position :Vector3 = Vector3(0, 15, 0)

var bot_id :int = -69
var bot_team :int = 69
var bot_town_center :BaseBuilding
var player_squads :Array = []
var enemy_squads :Array = []
var enemy_buildings :Array = []

onready var autobuilder :AutoBuilder = $autobuilder

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
	_squad.team = 1
	_squad.max_unit = 8
	_squad.position = squad_spawn_position + Vector3(0, _map.map_height, 0)
	
	.spawn_squad(_squad)
	
func on_ui_deploy_building(_building_data :BuildingData):
	.on_ui_deploy_building(_building_data)
	
	_building_data.player_id = NetworkLobbyManager.get_id()
	_building_data.node_name = GDUUID.v4()
	_building_data.network_master = NetworkLobbyManager.get_id()
	_building_data.color = color
	_building_data.team = 1
	_building_data.base_position = squad_spawn_position
	_building_data.max_distance_from_base = 24
	
	.on_deploying_building(_building_data)
	
################################################################
# bot & game
func all_player_ready():
	.all_player_ready()
	
	
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
		
	# deploy bot town center
	var town_center :BuildingData = preload("res://data/building_data/buildings/town_center.tres")
	town_center.player_id = bot_id
	town_center.node_name = "bot-town-center"
	town_center.network_master = Network.PLAYER_HOST_ID
	town_center.color = Color.red
	town_center.team = bot_team
	
	.on_deploying_building(town_center, _map.base_spawn_positions[4], true)
	
func on_squad_spawn(_squad :Squad, _icon :Resource):
	.on_squad_spawn(_squad, _icon)
	
	if _squad.player_id == bot_id:
		enemy_squads.append(_squad)
		
	else:
		player_squads.append(_squad)
	
func on_squad_dead(_squad :Squad):
	.on_squad_dead(_squad)
	
	if _squad.player_id == bot_id:
		enemy_squads.erase(_squad)
		
	else:
		player_squads.erase(_squad)
		
func on_building_deployed(_building :BaseBuilding):
	.on_building_deployed(_building)
	
	# enemy town center 
	# building is deployed
	if _building.player_id == bot_id and _building.name == "bot-town-center":
		bot_town_center = _building
		enemy_buildings.append(_building)
		
		# dont include enemy building
		# in global variable of buildings
		if _buildings.has(_building):
			_buildings.erase(_building)
		
func on_building_destroyed(_building :BaseBuilding):
	.on_building_destroyed(_building)
	
	# enemy town center 
	# building is destroyed
	if _building.player_id == bot_id and _building.name == "bot-town-center":
		bot_town_center = null
		
	if enemy_buildings.has(_building):
		enemy_buildings.erase(_building)
		
func _on_attack_wave_timer_timeout():
	if enemy_squads.size() > 3:
		return
		
	if not is_instance_valid(bot_town_center):
		return
		
	var squad_datas = [
		preload("res://data/squad_data/squads/pikeman_squad.tres"),
		preload("res://data/squad_data/squads/maceman_squad.tres"),
		preload("res://data/squad_data/squads/crossbowman_squad.tres"),
		preload("res://data/squad_data/squads/archer_squad.tres"),
		preload("res://data/squad_data/squads/axeman_squad.tres"),
		preload("res://data/squad_data/squads/militia_squad.tres"),
		preload("res://data/squad_data/squads/spearman_squad.tres"),
		preload("res://data/squad_data/squads/swordman_squad.tres"),
	]
	
	var squad :SquadData = squad_datas[rand_range(0, squad_datas.size())].duplicate()
	squad.player_id = bot_id
	squad.node_name = GDUUID.v4()
	squad.network_master = Network.PLAYER_HOST_ID
	squad.color = Color.red
	squad.team = bot_team
	squad.max_unit = 8
	squad.position = bot_town_center.translation + Vector3(0, _map.map_height + 5, 0)
	
	.spawn_squad(squad)
	
func _on_bot_attack_timer_timeout():
	if enemy_squads.empty():
		return
		
	if not is_instance_valid(bot_town_center):
		return
		
	var squads = enemy_squads.duplicate()
	squads.shuffle()
		
	var squad :Squad = null
	for i in squads:
		if not is_instance_valid(i):
			continue
			
		if i.is_in_combat() or i.is_moving:
			continue
			
		squad = i
		break
		
	if not is_instance_valid(squad):
		return
		
	var targets :Array = player_squads.duplicate() + _buildings.duplicate()
	if targets.empty():
		return
		
	targets.shuffle()
	
	var target = targets[0]
	for s in targets:
		if not is_instance_valid(target):
			continue
			
		if not is_instance_valid(s):
			continue
			
		var dis_1 = target.translation.distance_squared_to(squad.translation)
		var dis_2 = target.translation.distance_squared_to(s.translation)
		if dis_2 < dis_1:
			target = s
			
	if not is_instance_valid(target):
		return
		
	var attack_pos = target.translation.direction_to(
		squad.translation
	) * squad.combat_range
	
	squad.is_assault_mode = true
	squad.set_move_to(target.translation + attack_pos)

func _on_bot_buid_timer_timeout():
	if enemy_buildings.size() > 2:
		return
		
	if not is_instance_valid(bot_town_center):
		return
		
	# deploy bot tower
	var bot_building :BuildingData = preload("res://data/building_data/buildings/archer_tower.tres")
	bot_building.player_id = bot_id
	bot_building.node_name = GDUUID.v4()
	bot_building.network_master = Network.PLAYER_HOST_ID
	bot_building.color = Color.red
	bot_building.team = bot_team
	bot_building.base_position = bot_town_center.translation
	bot_building.max_distance_from_base = 24
	
	.on_deploying_building(bot_building)
	
func on_building_deplyoing(_building :BaseBuilding):
	
	# deploy find spot
	# using auto builder
	if _building.player_id == bot_id:
		autobuilder.translation = bot_town_center.translation
		autobuilder.building = _building
		autobuilder.find_placement()
		return
		
	.on_building_deplyoing(_building)
	
func _on_autobuilder_placement_found(_building :BaseBuilding, _pos :Vector3):
	_building.translation = _pos
	_building.start_building()















