extends Control

signal on_recruit_squad(_squad_data)

const squad_icon_scene = preload("res://assets/ui/gameplay/recruitment_panel/item/item.tscn")
const squad_datas = [
	preload("res://data/squad_data/squads/militia_squad.tres"),
	preload("res://data/squad_data/squads/spearman_squad.tres"),
	preload("res://data/squad_data/squads/archer_squad.tres"),
	preload("res://data/squad_data/squads/maceman_squad.tres"),
	
	preload("res://data/squad_data/squads/swordman_squad.tres"),
	preload("res://data/squad_data/squads/pikeman_squad.tres"),
	preload("res://data/squad_data/squads/crossbowman_squad.tres"),
	preload("res://data/squad_data/squads/sentinel_squad.tres"),
	
	preload("res://data/squad_data/squads/light_cavalry.tres"),
	preload("res://data/squad_data/squads/spear_cavalry.tres"),
	preload("res://data/squad_data/squads/archer_cavalry.tres"),
	preload("res://data/squad_data/squads/heavy_cavalry.tres")
]
var tier :int = 1
var player_coin :int = 0
var player_buildings :Array = []

onready var recruit_squad_icon_holder =  $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer3

onready var tier_1 = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer/tier_1
onready var tier_2 = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer/tier_2
onready var tier_3 = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer/tier_3

func _ready():
	set_process(false)
	
func display_squad_recruitment():
	for i in recruit_squad_icon_holder.get_children():
		recruit_squad_icon_holder.remove_child(i)
		i.queue_free()
		
	var datas :Array = []
	
	tier_1.disabled = false
	tier_2.disabled = false
	tier_3.disabled = false
	
	match (tier):
		1:
			datas = squad_datas.slice(0, 3)
			tier_1.disabled = true
		2:
			datas = squad_datas.slice(4, 7)
			tier_2.disabled = true
		3: 
			datas = squad_datas.slice(8, 11)
			tier_3.disabled = true
		
	for i in range(datas.size()):
		var data = datas[i]
		
		var instance  = squad_icon_scene.instance()
		instance.data = data
		instance.connect("on_click", self , "_on_recruit_squad_icon_click", [data])
		recruit_squad_icon_holder.add_child(instance)
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
		if not is_instance_valid(player_building):
			continue
			
		if _is_building_valid(player_building, id):
			return true
			
	return false
	
func _is_building_valid(_building :BaseBuilding, id:int):
	return _building.building_id == id and _building.status == BaseBuilding.status_deployed
	
func _process(delta):
	for i in recruit_squad_icon_holder.get_children():
		i.set_lock(
			not _is_building_ids_in_buildings(i.data.requirement_ids)
			, player_coin < i.data.price
		)
	
func _on_recruit_squad_icon_click(_squad_data :SquadData):
	visible = false
	emit_signal("on_recruit_squad", _squad_data)
	
func _on_close_recruit_squad_pressed():
	set_process(false)
	visible = false
	
func _on_tier_1_pressed():
	tier = 1
	display_squad_recruitment()
	
func _on_tier_2_pressed():
	tier = 2
	display_squad_recruitment()
	
func _on_tier_3_pressed():
	tier = 3
	display_squad_recruitment()
