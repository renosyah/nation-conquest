extends Control

signal on_main_menu_press

onready var _sfx_sound_setting_icon = $MarginContainer/VBoxContainer2/VBoxContainer3/HBoxContainer3/sfx_setting/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	check_sfx_setting()
	
func check_sfx_setting():
	if not Global.setting_data.is_sfx_mute:
		_sfx_sound_setting_icon.texture = preload("res://assets/ui/icon/checkbox_check.png")
	else:
		_sfx_sound_setting_icon.texture = preload("res://assets/ui/icon/checkbox_uncheck.png")

func _on_sfx_setting_pressed():
	Global.setting_data.is_sfx_mute = not Global.setting_data.is_sfx_mute
	Global.apply_setting_data()
	check_sfx_setting()
	
func _on_resume_pressed():
	visible = false
	
func _on_exit_pressed():
	emit_signal("on_main_menu_press")


