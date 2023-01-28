extends Node
class_name MPBot

signal bot_recruit_squad(_mpbot, _squad_data)
signal bot_deploying_building(_mpbot, _building_data)
signal bot_surrender(_mpbot)

const bot_difficulty_configs :Dictionary = {
	BotPlayerData.difficulty_easy : {
		"recruit_time" :18,
		"build_time" : 10,
		"action_time" : 8,
		"max_squads" : 3,
		"max_buildings" : 7,
		"uperhand_coin" : 25,
		"min_farm_required" : 3
	},
	BotPlayerData.difficulty_medium : {
		"recruit_time" :17,
		"build_time" : 8,
		"action_time" : 6,
		"max_squads" : 3,
		"max_buildings" : 7,
		"uperhand_coin" : 50,
		"min_farm_required" : 3
	},
	BotPlayerData.difficulty_hard : {
		"recruit_time" :16,
		"build_time" : 7,
		"action_time" : 5,
		"max_squads" : 4,
		"max_buildings" : 7,
		"uperhand_coin" : 70,
		"min_farm_required" : 4
	},
	BotPlayerData.difficulty_insane : {
		"recruit_time" :14,
		"build_time" : 5,
		"action_time" : 4,
		"max_squads" : 4,
		"max_buildings" : 8,
		"uperhand_coin" : 80,
		"min_farm_required" : 4
	}
}

export var bot_id :int = -69
export var bot_team :int = 69
export var bot_color :Color = Color.white

export var recruit_time :float = 15
export var build_time :float = 10
export var action_time :float = 2

export var max_squads :int = 3
export var max_buildings :int = 8
export var min_farm_required :int = 3

export var uperhand_coin :int = 100

var is_bot_surrender :bool = false

var enemy_squads :Array = []
var enemy_buildings :Array = []

var bot_squads :Array = []
var bot_buildings :Array = []

var bot_town_center :BaseBuilding
var autobuilder :AutoBuilder

var bot_coin :int = 100

var building_to_build :BuildingData

var recruit_timer :Timer
var build_timer :Timer
var action_timer :Timer

var uperhand_timer :Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	autobuilder = preload("res://assets/autobuilder/autobuilder.tscn").instance()
	autobuilder.connect("placement_found", self, "_on_placement_found")
	autobuilder.connect("placement_not_found", self, "_on_placement_not_found")
	add_child(autobuilder)
	
	recruit_timer = Timer.new()
	recruit_timer.wait_time = rand_range(recruit_time - 2, recruit_time + 2)
	recruit_timer.autostart = true
	recruit_timer.one_shot = false
	recruit_timer.connect("timeout", self , "_on_recruit_timer")
	add_child(recruit_timer)
	
	build_timer = Timer.new()
	build_timer.wait_time = rand_range(build_time - 3, build_time + 3)
	build_timer.autostart = true
	build_timer.one_shot = false
	build_timer.connect("timeout", self , "_on_build_timer")
	add_child(build_timer)
	
	action_timer = Timer.new()
	action_timer.wait_time = rand_range(action_time - 2, action_time + 2)
	action_timer.autostart = true
	action_timer.one_shot = false
	action_timer.connect("timeout", self , "_on_action_timer")
	add_child(action_timer)
	
	uperhand_timer = Timer.new()
	uperhand_timer.wait_time = rand_range(25 - 2, 25 + 2)
	uperhand_timer.autostart = true
	uperhand_timer.one_shot = false
	uperhand_timer.connect("timeout", self , "_on_uperhand_timer")
	add_child(uperhand_timer)
	
func get_town_center_data() -> BuildingData:
	var town_center :BuildingData = preload("res://data/building_data/buildings/town_center.tres")
	town_center.player_id = bot_id
	town_center.node_name = "bot-town-center-" + str(bot_id)
	town_center.network_master = Network.PLAYER_HOST_ID
	town_center.color = bot_color
	town_center.team = bot_team
	return town_center

func _on_recruit_timer():
	if not is_instance_valid(bot_town_center):
		return
		
	if not is_bot_have_farm():
		return
		
	if bot_squads.size() > max_squads:
		return
		
	var _squads :Array = [
		preload("res://data/squad_data/squads/pikeman_squad.tres"),
		preload("res://data/squad_data/squads/maceman_squad.tres"),
		preload("res://data/squad_data/squads/crossbowman_squad.tres"),
		preload("res://data/squad_data/squads/archer_squad.tres"),
		preload("res://data/squad_data/squads/axeman_squad.tres"),
		preload("res://data/squad_data/squads/militia_squad.tres"),
		preload("res://data/squad_data/squads/spearman_squad.tres"),
		preload("res://data/squad_data/squads/swordman_squad.tres"),
		preload("res://data/squad_data/squads/light_cavalry.tres"),
		preload("res://data/squad_data/squads/spearman_squad.tres"),
		preload("res://data/squad_data/squads/archer_cavalry.tres"),
		preload("res://data/squad_data/squads/heavy_cavalry.tres")
	]
	
	_squads.invert()
	
	var squad :SquadData = null
	for s in _squads:
		if not _is_building_ids_in_buildings(s.requirement_ids):
			continue
			
		if bot_coin > s.price:
			squad = s.duplicate()
			break
		
	if squad == null:
		return
		
	bot_coin -= squad.price
	
	squad.player_id = bot_id
	squad.player_name = ""
	squad.node_name = "BOT_SQUAD_" + GDUUID.v4() + "-" + str(bot_id)
	squad.network_master = Network.PLAYER_HOST_ID
	squad.color = bot_color
	squad.team = bot_team
	squad.position = bot_town_center.translation + Vector3(0, 10, 0)
	
	emit_signal("bot_recruit_squad", self, squad)
	
func _on_build_timer():
	if not is_instance_valid(bot_town_center):
		return
		
	if bot_buildings.size() > max_buildings:
		return
		
	if building_to_build != null:
		return
		
	var _buildings :Array = [
		preload("res://data/building_data/buildings/farm.tres"),
		preload("res://data/building_data/buildings/archer_tower.tres"),
		preload("res://data/building_data/buildings/barrack.tres"),
		preload("res://data/building_data/buildings/shooting_range.tres"),
		preload("res://data/building_data/buildings/blacksmith.tres"),
		preload("res://data/building_data/buildings/healing_camp.tres"),
		preload("res://data/building_data/buildings/stable.tres")
	]
	
	if get_bot_farm_count() < min_farm_required:
		
		var farm_building = _buildings[0].duplicate()
		if bot_coin > farm_building.price:
			building_to_build = farm_building
			
	else:
		
		_buildings.invert()
		for s in _buildings:
			if _is_max_out_building_count(s.building_id, s.max_building_count):
				continue
				
			if not _is_building_ids_in_buildings(s.requirement_ids):
				continue
				
			if bot_coin > s.price:
				building_to_build = s.duplicate()
				break
		
	if building_to_build == null:
		return
		
	building_to_build.player_id = bot_id
	building_to_build.node_name = "BOT_BUILDING_" + GDUUID.v4() + "-" + str(bot_id)
	building_to_build.network_master = Network.PLAYER_HOST_ID
	building_to_build.color = bot_color
	building_to_build.team = bot_team
	building_to_build.base_position = bot_town_center.translation
	building_to_build.max_distance_from_base = 24
	
	emit_signal("bot_deploying_building", self, building_to_build)
	
	
func start_find_placement(_building :BaseBuilding, ignores :Array = [], exceptions :Array = []):
	if not is_instance_valid(bot_town_center):
		return
		
	autobuilder.radius = rand_range(14.0, 22.0)
	autobuilder.duration = rand_range(4.0, 10.0)
	autobuilder.speed = rand_range(0.5, 1.5)
	autobuilder.ignore = ignores
	autobuilder.with_direction = randf() < 0.4
	autobuilder.direction = autobuilder.directions[rand_range(0, autobuilder.directions.size())]
	autobuilder.exceptions = exceptions
	autobuilder.translation = bot_town_center.translation
	autobuilder.building = _building
	autobuilder.find_placement()
	
func _on_placement_found(_building :BaseBuilding, _pos :Vector3):
	bot_coin -= building_to_build.price
	building_to_build = null
	
	_building.translation = _pos
	_building.start_building()
	
	bot_buildings.append(_building)
	
func _on_placement_not_found(_building :BaseBuilding):
	building_to_build = null
	_building.demolish()
	
func _on_action_timer():
	if not is_instance_valid(bot_town_center):
		return
		
	if bot_squads.empty():
		return
		
	var healing_camp :HealingCamp = null
	for building in bot_buildings:
		if building is HealingCamp:
			healing_camp = building
			break
			
	if is_instance_valid(healing_camp):
		for bot_squad in bot_squads:
			if bot_squad.unit_size() < bot_squad.max_unit:
				bot_squad.set_move_to(healing_camp.global_transform.origin)
		
	var squads_copy :Array = bot_squads.duplicate()
	squads_copy.shuffle()
		
	var squad :Squad = null
	for i in squads_copy:
		if not is_instance_valid(i):
			continue
			
		if i.is_in_combat() or i.is_moving:
			continue
			
		squad = i
		break
		
	if not is_instance_valid(squad):
		return
		
	var targets :Array = enemy_squads + enemy_buildings
	if targets.empty():
		return
		
	var target = targets[rand_range(0, targets.size())]
	if not is_instance_valid(target):
		return
		
	squad.is_assault_mode = true
	squad.set_attack_to(target.translation)
	
func _on_uperhand_timer():
	bot_coin += uperhand_coin
	
func on_squad_spawn(_squad:Squad):
	if is_bot_surrender:
		return
		
	if _squad.team == bot_team:
		if _squad.player_id == bot_id:
			bot_squads.append(_squad)
	else:
		enemy_squads.append(_squad)
	
func on_squad_dead(_squad :Squad):
	if is_bot_surrender:
		return
		
	if _squad.team == bot_team:
		if _squad.player_id == bot_id and bot_squads.has(_squad):
			bot_squads.erase(_squad)
	else:
		if enemy_squads.has(_squad):
			enemy_squads.erase(_squad)
			
	
func on_building_deployed(_building :BaseBuilding):
	if is_bot_surrender:
		return
		
	if _building.team == bot_team:
		if _building.player_id == bot_id:
			if _building.name == "bot-town-center-" + str(bot_id):
				bot_town_center = _building
				autobuilder.translation = bot_town_center.translation
				
			if _building in bot_buildings:
				return
				
			bot_buildings.append(_building)
			
			if _building is Farm:
				_building.connect("harvest_time", self,"on_harvest_time")
		
	else:
		enemy_buildings.append(_building)
		
func on_building_destroyed(_building :BaseBuilding):
	if is_bot_surrender:
		return
		
	if _building.team == bot_team:
		if _building.name == "bot-town-center-" + str(bot_id):
			bot_town_center = null
			surrender()
			
		if bot_buildings.has(_building):
			bot_buildings.erase(_building)
			
	else:
		if enemy_buildings.has(_building):
			enemy_buildings.erase(_building)
	
func on_harvest_time(_building :Farm, _amount :int):
	bot_coin += _amount

func surrender():
	is_bot_surrender = true
	
	for squad in bot_squads:
		if not is_instance_valid(squad):
			continue
			
		squad.disband()
		
	for building in bot_buildings:
		if not is_instance_valid(building):
			continue
			
		if building is TownCenter:
			continue
			
		building.demolish()
		
	action_timer.stop()
	build_timer.stop()
	recruit_timer.stop()
	uperhand_timer.stop()
	
	emit_signal("bot_surrender", self)

func get_bot_farm_count() -> int:
	var count :int = 0
	for building in bot_buildings:
		if not is_instance_valid(building):
			continue
			
		if building is Farm:
			count += 1
			
	return count

func is_bot_have_farm() -> bool:
	return get_bot_farm_count() > 0
	
func _is_max_out_building_count(building_id :int, max_building_count :int):
	if bot_buildings.empty():
		return false
		
	if max_building_count == -1:
		return false
		
	var count :int = 0
	for bot_building in bot_buildings:
		if bot_building.building_id == building_id:
			count += 1
		
	# exceed quota
	return max_building_count <= count
	
func _is_building_ids_in_buildings(building_ids :Array) -> bool:
	if bot_buildings.empty():
		return false
		
	var req_count :int = building_ids.size()
	var req_satisfy :int = 0
	
	for id in building_ids:
		if _requirement_id_in_buildings(id):
			req_satisfy += 1
			
			if req_satisfy == req_count:
				return true
				
			continue
		
	return false
	
func _requirement_id_in_buildings(id :int) -> bool:
	for bot_building in bot_buildings:
		if not is_instance_valid(bot_building):
			continue
			
		if _is_building_valid(bot_building, id):
			return true
			
	return false
	
func _is_building_valid(_building :BaseBuilding, id:int):
	return _building.building_id == id and _building.status == BaseBuilding.status_deployed
	




