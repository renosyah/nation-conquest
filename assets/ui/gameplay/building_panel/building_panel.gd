extends Control

signal on_construct_building(_building_data)

const building_item_scene = preload("res://assets/ui/gameplay/building_panel/item/item.tscn")

var player_coin :int = 0
onready var building_panel_icon_holder = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer3

func _ready():
	set_process(false)

func display_building_panel():
	for i in building_panel_icon_holder.get_children():
		building_panel_icon_holder.remove_child(i)
		i.queue_free()
		
	var building_datas = [
		preload("res://data/building_data/buildings/town_center.tres"),
		preload("res://data/building_data/buildings/farm.tres"),
		preload("res://data/building_data/buildings/archer_tower.tres"),
	]
	
	for i in range(building_datas.size()):
		var data = building_datas[i].duplicate()
		
		var instance = building_item_scene.instance()
		instance.data = data
		instance.is_locked = true
		instance.connect("on_click", self , "_on_building_panel_icon_click", [data])
		building_panel_icon_holder.add_child(instance)
		
	set_process(true)
	
func _process(delta):
	for i in building_panel_icon_holder.get_children():
		i.set_lock(player_coin < i.data.price)
		
func _on_building_panel_icon_click( _building :BuildingData):
	emit_signal("on_construct_building", _building)

func _on_close_base_building_pressed():
	set_process(false)
	visible = false
