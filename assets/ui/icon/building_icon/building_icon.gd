extends MarginContainer
class_name BuildingIcon

signal on_click(_icon)

export var icon :Resource
export var title :String
export var color :Color = Color.white

onready var _icon = $Control/VBoxContainer2/HBoxContainer/TextureRect
onready var _input_detection = $input_detection
onready var _label = $Control/VBoxContainer2/MarginContainer2/VBoxContainer/Label
onready var _frame_2 = $Control/Frame2

# Called when the node enters the scene tree for the first time.
func _ready():
	_icon.texture = icon
	_label.text = title
	_frame_2.color = color

func _on_building_icon_gui_input(event):
	_input_detection.check_input(event)

func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click", self)



