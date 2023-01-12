extends Node
class_name MPBot

signal bot_recruit_squad(_mpbot, _squad_data)
signal bot_deploying_building(_mpbot, _building_data)

const squad_datas = [
	preload("res://data/squad_data/squads/pikeman_squad.tres"),
	preload("res://data/squad_data/squads/maceman_squad.tres"),
	preload("res://data/squad_data/squads/crossbowman_squad.tres"),
	preload("res://data/squad_data/squads/archer_squad.tres"),
	preload("res://data/squad_data/squads/axeman_squad.tres"),
	preload("res://data/squad_data/squads/militia_squad.tres"),
	preload("res://data/squad_data/squads/spearman_squad.tres"),
	preload("res://data/squad_data/squads/swordman_squad.tres"),
]

const building_datas = [
	preload("res://data/building_data/buildings/farm.tres"),
	preload("res://data/building_data/buildings/archer_tower.tres")
]

export var bot_id :int = -69
export var bot_team :int = 69
export var bot_color :Color = Color.white

export var recruit_time :float = 15
export var build_time :float = 10
export var action_time :float = 2

export var max_squads :int = 3
export var max_buildings :int = 2

var enemy_squads :Array = []
var enemy_buildings :Array = []

var bot_squads :Array = []
var bot_buildings :Array = []

var bot_town_center :BaseBuilding
var autobuilder :AutoBuilder

var bot_coin :int = 100

var recruit_timer :Timer
var build_timer :Timer
var action_timer :Timer

var uperhand_timer :Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	autobuilder = preload("res://assets/autobuilder/autobuilder.tscn").instance()
	autobuilder.connect("placement_found", self, "_on_placement_found")
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
	town_center.team =bot_team
	return town_center

func _on_recruit_timer():
	if not is_instance_valid(bot_town_center):
		return
		
	if not is_bot_have_farm():
		return
		
		
	if bot_squads.size() > max_squads:
		return
		
	var _squads :Array = squad_datas.duplicate()
	_squads.shuffle()
	
	var squad :SquadData = null
	for s in _squads:
		if bot_coin > s.price:
			squad = s
			break
		
	if squad == null:
		return
		
	bot_coin -= squad.price
	
	squad.player_id = bot_id
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
		
	var _buildings :Array = building_datas.duplicate()
	_buildings.shuffle()
	
	var bot_building :BuildingData = null
	for s in _buildings:
		if bot_coin > s.price:
			bot_building = s
			break
		
	if bot_building == null:
		return
		
	bot_coin -= bot_building.price
	
	bot_building.player_id = bot_id
	bot_building.node_name = "BOT_BUILDING_" + GDUUID.v4() + "-" + str(bot_id)
	bot_building.network_master = Network.PLAYER_HOST_ID
	bot_building.color = bot_color
	bot_building.team = bot_team
	bot_building.base_position = bot_town_center.translation
	bot_building.max_distance_from_base = 24
	
	emit_signal("bot_deploying_building", self, bot_building)
	
	
func start_find_placement(_building :BaseBuilding, ignores :Array = [], exceptions :Array = []):
	if not is_instance_valid(bot_town_center):
		return
		
	autobuilder.ignore = ignores
	autobuilder.exceptions = exceptions
	autobuilder.translation = bot_town_center.translation
	autobuilder.building = _building
	autobuilder.find_placement()
	
func _on_placement_found(_building :BaseBuilding, _pos :Vector3):
	_building.translation = _pos
	_building.start_building()
	
func _on_action_timer():
	if bot_squads.empty():
		return
		
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
		
	var targets_copy :Array = enemy_squads.duplicate() + enemy_buildings.duplicate()
	if targets_copy.empty():
		return
		
	targets_copy.shuffle()
	
	var target = targets_copy[0]
	for s in targets_copy:
		if not is_instance_valid(target) or not is_instance_valid(s):
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
	
func _on_uperhand_timer():
	if not is_bot_have_farm():
		bot_coin += 100
	
func on_squad_spawn(_squad:Squad):
	if _squad.team == bot_team:
		if _squad.player_id == bot_id:
			bot_squads.append(_squad)
	else:
		enemy_squads.append(_squad)
	
func on_squad_dead(_squad :Squad):
	if _squad.team == bot_team:
		if _squad.player_id == bot_id and bot_squads.has(_squad):
			bot_squads.erase(_squad)
	else:
		if enemy_squads.has(_squad):
			enemy_squads.erase(_squad)
			
	
	
func on_building_deployed(_building :BaseBuilding):
	if _building.team == bot_team:
		if _building.player_id == bot_id:
			if _building.name == "bot-town-center-" + str(bot_id):
				bot_town_center = _building
				autobuilder.translation = bot_town_center.translation
				
			bot_buildings.append(_building)
			
			if _building is Farm:
				_building.connect("harvest_time", self,"on_harvest_time")
		
	else:
		enemy_buildings.append(_building)
		
func on_building_destroyed(_building :BaseBuilding):
	if _building.team == bot_team:
		if _building.name == "bot-town-center-" + str(bot_id):
			bot_town_center = null
			
		if bot_buildings.has(_building):
			bot_buildings.erase(_building)
			
	else:
		if enemy_buildings.has(_building):
			enemy_buildings.erase(_building)
	
func on_harvest_time(_building :Farm, _amount :int):
	bot_coin += _amount


func is_bot_have_farm() -> bool:
	for building in bot_buildings:
		if not is_instance_valid(building):
			continue
			
		if building is Farm:
			return true
			
	return false
	






