extends Control

onready var _sfx_sound_setting_icon = $SafeArea/VBoxContainer2/HBoxContainer3/sfx_setting/TextureRect
onready var _input_name = $input_name
onready var _player_name_ui = $SafeArea/VBoxContainer2/HBoxContainer2/VBoxContainer/Label4

# Called when the node enters the scene tree for the first time.
func _ready():
	_input_name.visible = false
	_player_name_ui.text = Global.player.player_name
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
	
func _on_exit_pressed():
	visible = false

func _on_name_setting_pressed():
	_input_name.visible = true

func _on_input_name_on_continue(_player_name, html_color):
	Global.player.player_name = _player_name
	_player_name_ui.text = Global.player.player_name
