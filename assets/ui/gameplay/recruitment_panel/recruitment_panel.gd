extends Control

signal on_recruit_squad(_squad_data)

const squad_icon_scene = preload("res://assets/ui/gameplay/recruitment_panel/item/item.tscn")
const squad_datas = [
	preload("res://data/squad_data/squads/militia_squad.tres"),
	preload("res://data/squad_data/squads/spearman_squad.tres"),
	preload("res://data/squad_data/squads/archer_squad.tres"),
	preload("res://data/squad_data/squads/axeman_squad.tres"),
	preload("res://data/squad_data/squads/swordman_squad.tres"),
	preload("res://data/squad_data/squads/pikeman_squad.tres"),
	preload("res://data/squad_data/squads/crossbowman_squad.tres"),
	preload("res://data/squad_data/squads/maceman_squad.tres"),
]
onready var recruit_squad_icon_holder = $HBoxContainer2/Panel/VBoxContainer/ScrollContainer/HBoxContainer3

func display_squad_recruitment():
	for i in recruit_squad_icon_holder.get_children():
		recruit_squad_icon_holder.remove_child(i)
		i.queue_free()
		
	for i in range(squad_datas.size()):
		var data = squad_datas[i].duplicate()
		
		var instance  = squad_icon_scene.instance()
		instance.data = data
		instance.connect("on_click", self , "_on_recruit_squad_icon_click", [data])
		recruit_squad_icon_holder.add_child(instance)
		
func _on_recruit_squad_icon_click(_squad_data :SquadData):
	visible = false
	emit_signal("on_recruit_squad", _squad_data)
	
func _on_close_recruit_squad_pressed():
	visible = false
