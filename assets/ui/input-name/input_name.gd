extends Control

signal on_close()
signal on_continue(_player_name, html_color)

onready var _rng = RandomNumberGenerator.new()
onready var _input_color_button_color = $Panel/VBoxContainer/HBoxContainer2/choose_color/ColorRect
onready var _ready_button = $Panel/VBoxContainer/HBoxContainer/continue
onready var _input_name = $Panel/VBoxContainer/HBoxContainer2/input_name

var player_name = ""
var html_color = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	_input_name.text = player_name
	_rng.randomize()
	_ready_button.disabled = true
	_on_choose_color_pressed()
	
func set_player_name(_name):
	player_name = _name
	_input_name.text = player_name
	
func _on_continue_pressed():
	player_name = _input_name.text
	visible = false
	emit_signal("on_continue", player_name, html_color)
	
func _on_input_name_text_changed(new_text):
	_ready_button.disabled = str(new_text).empty()


func _on_button_close_pressed():
	visible = false
	emit_signal("on_close")


func _on_choose_color_pressed():
	var _color = Color(_rng.randf(),_rng.randf(),_rng.randf(),1.0)
	html_color = _color.to_html()
	_input_color_button_color.color = _color
	
	
	
	
	
	
