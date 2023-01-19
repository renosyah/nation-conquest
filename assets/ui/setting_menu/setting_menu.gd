extends Control

const check = preload("res://assets/ui/icon/checkbox_check.png")
const uncheck = preload("res://assets/ui/icon/checkbox_uncheck.png")

onready var _input_name = $input_name
onready var _input_color = $input_color

onready var _player_name_ui = $SafeArea/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/VBoxContainer/player_name
onready var _player_color = $SafeArea/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/VBoxContainer2/color_setting/player_color

onready var _sfx_sound_setting_icon = $SafeArea/VBoxContainer2/ScrollContainer/VBoxContainer/VBoxContainer3/HBoxContainer3/sfx_setting/TextureRect
onready var _potrait_setting_icon =  $SafeArea/VBoxContainer2/ScrollContainer/VBoxContainer/VBoxContainer4/HBoxContainer3/HBoxContainer/potrait_setting/TextureRect
onready var _landscape_setting_icon =  $SafeArea/VBoxContainer2/ScrollContainer/VBoxContainer/VBoxContainer4/HBoxContainer3/HBoxContainer2/landscape_setting/TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	_input_name.visible = false
	_input_color.visible = false
	
	_player_name_ui.text = Global.player.player_name
	_player_color.color = Global.player.player_color
	
	check_sfx_setting()
	check_orientation_setting()
	
func check_sfx_setting():
	if not Global.setting_data.is_sfx_mute:
		_sfx_sound_setting_icon.texture = check
	else:
		_sfx_sound_setting_icon.texture = uncheck
		
func check_orientation_setting():
	match (Global.setting_data.screen_orientation):
		#OS.SCREEN_ORIENTATION_LANDSCAPE:
		0:
			_potrait_setting_icon.texture = uncheck
			_landscape_setting_icon.texture = check
			
		#OS.SCREEN_ORIENTATION_POTRAIT:
		1:
			_potrait_setting_icon.texture = check
			_landscape_setting_icon.texture = uncheck
			
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

func _on_landscape_setting_pressed():
	Global.setting_data.screen_orientation = 0 #OS.SCREEN_ORIENTATION_LANDSCAPE
	OS.screen_orientation = OS.SCREEN_ORIENTATION_LANDSCAPE
	OS.window_size = Vector2(1024, 600)
	check_orientation_setting()

func _on_potrait_setting_pressed():
	Global.setting_data.screen_orientation = 1 #OS.SCREEN_ORIENTATION_POTRAIT
	OS.screen_orientation = OS.SCREEN_ORIENTATION_PORTRAIT
	OS.window_size = Vector2(600, 1024)
	check_orientation_setting()

func _on_color_setting_pressed():
	_input_color.visible = true

func _on_input_color_on_pick(_color :Color):
	Global.player.player_color = _color
	_player_color.color = Global.player.player_color
	
 
