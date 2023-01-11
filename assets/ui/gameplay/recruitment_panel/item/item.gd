extends MarginContainer

signal on_click

var data :SquadData
var is_locked :bool = true

onready var texture_rect =  $Control/VBoxContainer2/HBoxContainer/TextureRect
onready var building_name = $Control/VBoxContainer2/MarginContainer2/VBoxContainer/Label
onready var frame_2 = $Control/Frame2
onready var label_2 = $Control/VBoxContainer2/HBoxContainer/TextureRect/VBoxContainer/ColorRect/Label2

onready var input_detection = $input_detection
onready var lock = $Control/lock

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_rect.texture = data.icon
	building_name.text =  data.squad_name
	label_2.text = "Food : 90"
	frame_2.color = Color.gray
	lock.visible = is_locked
	
func _on_item_gui_input(event):
	if is_locked:
		return
		
	input_detection.check_input(event)

func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click")



