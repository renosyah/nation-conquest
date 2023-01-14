extends Control

signal on_main_menu_press

onready var label_2 = $MarginContainer/VBoxContainer2/Label2
onready var label_3 = $MarginContainer/VBoxContainer2/HBoxContainer2/Label3
onready var main_menu = $SafeArea/VBoxContainer/HBoxContainer/main_menu

onready var margin_container = $MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	margin_container.visible = false
	main_menu.visible = false

func set_condition(is_win :bool):
	label_2.text = "Victory" if is_win else "Defeat"
	label_3.text = "All Enemy Town Center Destroyed!" if is_win else "Your Town Center Has Been Destroyed!"
	margin_container.visible = true

func _on_main_menu_pressed():
	emit_signal("on_main_menu_press")

func _on_continue_pressed():
	margin_container.visible = false
	main_menu.visible = true
