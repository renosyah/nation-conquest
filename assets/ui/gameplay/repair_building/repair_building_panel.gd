extends Control

signal repair

onready var label_2 = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/Label2
onready var yes = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer/yes

func set_repair_cost(repair_cost :int):
	yes.disabled = repair_cost == 0
	label_2.text = "Repair Cost : " + str(repair_cost)
	
func _on_yes_pressed():
	visible = false
	emit_signal("repair")

func _on_no_pressed():
	visible = false
