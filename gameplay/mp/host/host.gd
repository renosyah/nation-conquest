extends BaseGameplay

onready var color :Color = Color(randf(), randf(), randf(), 1)
onready var player_squad_holder = $player_squad_holder
onready var squad_spawn_position :Vector3 = Vector3(0, 15, 0)

var bot_town_center :BaseBuilding
onready var enemy_squad_holder = $enemy_squad_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func all_player_ready():
	.all_player_ready()
	
	for player in NetworkLobbyManager.get_players():
		var base_spawn_position :Vector3 = Vector3(0, 0, 0)
		
		if _player_base_spawn_position.has(player.player_network_unique_id):
			base_spawn_position = _player_base_spawn_position[player.player_network_unique_id]
			
		var town_center :BuildingData = preload("res://data/building_data/buildings/town_center.tres")
		town_center.node_name = GDUUID.v4()
		town_center.network_master = player.player_network_unique_id
		town_center.color = color
		town_center.team = 1
		
		.on_deploying_building(town_center, base_spawn_position, true)
		
		
	var town_center :BuildingData = preload("res://data/building_data/buildings/town_center.tres")
	town_center.node_name = "bot-town-center"
	town_center.network_master = Network.PLAYER_HOST_ID
	town_center.color = Color.red
	town_center.team = 2
	
	.on_deploying_building(town_center, _map.base_spawn_positions[4], true)
	
func on_building_deployed(_building :BaseBuilding):
	.on_building_deployed(_building)
	
	if _building.name == "bot-town-center":
		bot_town_center = _building
		_buildings.erase(_building)
	
func on_generate_map_completed():
	.on_generate_map_completed()
	
	if _player_base_spawn_position.has(NetworkLobbyManager.get_id()):
		squad_spawn_position = _player_base_spawn_position[NetworkLobbyManager.get_id()]
		_camera.translation = squad_spawn_position
	
	NetworkLobbyManager.set_host_ready()
	
func on_ui_recruit_squad(_squad :SquadData):
	.on_ui_recruit_squad(_squad)
	
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = color
	_squad.team = 1
	
	.spawn_squad(
		_squad, squad_spawn_position + Vector3(0, _map.map_height, 0), 
		player_squad_holder.get_path()
	)
	
func on_ui_deploy_building(_building_data :BuildingData):
	.on_ui_deploy_building(_building_data)
	
	_building_data.node_name = GDUUID.v4()
	_building_data.network_master = NetworkLobbyManager.get_id()
	_building_data.color = color
	_building_data.team = 1
	
	.on_deploying_building(_building_data)
	
################################################################
# bot

func get_invasion_spawn_pos() -> Vector3:
	return bot_town_center.translation + Vector3(0, _map.map_height + 5, 0)
	
func _on_attack_wave_timer_timeout():
	if enemy_squad_holder.get_child_count() > 6:
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
	
	var squad = squad_datas[rand_range(0, squad_datas.size())].duplicate()
	squad.node_name = GDUUID.v4()
	squad.network_master = Network.PLAYER_HOST_ID
	squad.color = Color.red
	squad.team = 2
	
	spawn_squad(
		squad, get_invasion_spawn_pos(), enemy_squad_holder.get_path()
	)
	
func _on_bot_attack_timer_timeout():
	if enemy_squad_holder.get_child_count() < 1:
		return
		
	if not is_instance_valid(bot_town_center):
		return
		
	var squads = enemy_squad_holder.get_children().duplicate()
	squads.shuffle()
		
	var squad :Squad = null
	for i in squads:
		if i.is_in_combat() or i.is_moving:
			continue
			
		squad = i
		break
		
	if not is_instance_valid(squad):
		return
		
	var targets :Array = player_squad_holder.get_children().duplicate() + _buildings
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
	
	
	
