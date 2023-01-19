extends Control

onready var label = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/Label
onready var label_2 = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer/Label2
onready var texture_rect = $CenterContainer/MarginContainer/HBoxContainer2/VBoxContainer/HBoxContainer/TextureRect

func set_info(_name, _description :String, _icon :Resource):
	label.text = _name
	label_2.text = _description
	texture_rect.texture = _icon
	
func _on_close_pressed():
	visible = false
