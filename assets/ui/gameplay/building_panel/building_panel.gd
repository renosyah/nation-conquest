extends Control

signal on_construct_building(_building_data)

const building_item_scene = preload("res://assets/ui/gameplay/building_panel/item/item.tscn")

onready var building_panel_icon_holder = $HBoxContainer2/Panel/VBoxContainer/ScrollContainer/HBoxContainer3

func display_building_panel():
	for i in building_panel_icon_holder.get_children():
		building_panel_icon_holder.remove_child(i)
		i.queue_free()

	var building_datas = [
		preload("res://data/building_data/archer_tower.tres")
	]

	for i in range(building_datas.size()):
		var data = building_datas[i].duplicate()
		
		var instance = building_item_scene.instance()
		instance.data = data
		instance.connect("on_click", self , "_on_building_panel_icon_click", [data])
		building_panel_icon_holder.add_child(instance)
		
func _on_building_panel_icon_click( _building :BuildingData):
	emit_signal("on_construct_building", _building)

func _on_close_build_building_pressed():
	visible = false
