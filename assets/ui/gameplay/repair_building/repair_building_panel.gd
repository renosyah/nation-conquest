extends Control

signal repair

onready var label_2 = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/Label2

func set_repair_cost(repair_cost :int):
	label_2.text = "Repair Cost : " + str(repair_cost)
	
func _on_yes_pressed():
	visible = false
	emit_signal("repair")

func _on_no_pressed():
	visible = false
