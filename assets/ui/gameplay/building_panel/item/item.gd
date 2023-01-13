extends MarginContainer

signal on_click

var data :BuildingData

onready var texture_rect = $Control/VBoxContainer2/HBoxContainer/TextureRect
onready var building_name = $Control/VBoxContainer2/MarginContainer2/VBoxContainer/HBoxContainer/Label
onready var frame_2 = $Control/Frame2
onready var label_2 = $Control/VBoxContainer2/HBoxContainer/TextureRect/VBoxContainer/ColorRect/HBoxContainer/Label2

onready var input_detection = $input_detection
onready var lock = $Control/lock
onready var unfunded = $Control/unfunded

var can_click :bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_rect.texture = data.icon
	building_name.text = data.building_name
	label_2.text = str(data.price)
	frame_2.color = Color(0.242188, 0.242188, 0.242188)
	lock.visible = false
	unfunded.visible = false
	
func set_lock(_is_locked: bool, _is_expensive: bool):
	lock.visible = false
	unfunded.visible = false
	can_click = false
	
	lock.visible = _is_locked
	if _is_locked:
		return
		
	unfunded.visible = _is_expensive
	can_click = not _is_expensive
	
func _on_item_gui_input(event):
	if not can_click:
		return
		
	input_detection.check_input(event)

func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click")



