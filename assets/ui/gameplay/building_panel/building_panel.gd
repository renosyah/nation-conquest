extends Control

signal on_construct_building(_building_data)

const building_item_scene = preload("res://assets/ui/gameplay/building_panel/item/item.tscn")

var player_coin :int = 0
var player_buildings :Array = []

onready var building_panel_icon_holder = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer3

func _ready():
	set_process(false)

func display_building_panel():
	for i in building_panel_icon_holder.get_children():
		building_panel_icon_holder.remove_child(i)
		i.queue_free()
		
	var building_datas = [
		#preload("res://data/building_data/buildings/town_center.tres"),
		preload("res://data/building_data/buildings/farm.tres"),
		preload("res://data/building_data/buildings/archer_tower.tres"),
		preload("res://data/building_data/buildings/barrack.tres"),
		preload("res://data/building_data/buildings/shooting_range.tres"),
		preload("res://data/building_data/buildings/blacksmith.tres"),
		preload("res://data/building_data/buildings/healing_camp.tres"),
		preload("res://data/building_data/buildings/stable.tres")
	]
	
	for i in range(building_datas.size()):
		var data = building_datas[i].duplicate()
		
		var instance = building_item_scene.instance()
		instance.data = data
		instance.connect("on_click", self , "_on_building_panel_icon_click", [data])
		building_panel_icon_holder.add_child(instance)
		instance.set_lock(
			not _is_building_ids_in_buildings(data.requirement_ids), 
			player_coin < data.price
		)
		
	set_process(true)
	
func _is_building_ids_in_buildings(building_ids :Array) -> bool:
	if player_buildings.empty():
		return false
		
	var req_count :int = building_ids.size()
	var req_satisfy :int = 0
	
	for id in building_ids:
		if _is_id_in_buildings(id):
			req_satisfy += 1
			
			if req_satisfy == req_count:
				return true
				
			continue
		
	return false
	
func _is_id_in_buildings(id :int) -> bool:
	for player_building in player_buildings:
		if _is_building_valid(player_building, id):
			return true
			
	return false
	
func _is_building_valid(_building :BaseBuilding, id:int):
	return _building.building_id == id and _building.status == BaseBuilding.status_deployed
	
func _process(delta):
	for i in building_panel_icon_holder.get_children():
		i.set_lock(
			not _is_building_ids_in_buildings(i.data.requirement_ids), 
			player_coin < i.data.price
		)
		
func _on_building_panel_icon_click( _building :BuildingData):
	emit_signal("on_construct_building", _building)
	
func _on_close_base_building_pressed():
	set_process(false)
	visible = false
