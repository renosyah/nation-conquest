extends MarginContainer
class_name SquadIcon

signal on_click(_icon)

export var icon :Resource
export var title :String
export var color :Color = Color.white
export var is_selected :bool = false

onready var _icon = $Control/VBoxContainer2/HBoxContainer/TextureRect
onready var _input_detection = $input_detection
onready var _frame = $Control/Frame
onready var _label = $Control/VBoxContainer2/MarginContainer2/VBoxContainer/Label
onready var _frame_2 = $Control/Frame2
onready var _frame_3 = $Control/Frame3
onready var _frame_4 = $Control/Frame4
onready var _tween = $Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	_icon.texture = icon
	_label.text = title
	_frame.modulate = Color.transparent
	_frame_2.modulate = color
	_frame_3.modulate.a = 0
	_frame_4.modulate.a = 0
	
func set_selected(val :bool):
	is_selected = val
	_frame.modulate = Color.white if is_selected else Color.transparent

func update_unit_size(_val :int):
	_label.text = str(_val)

func show_squad_hurt():
	_tween.interpolate_property(_frame_3, "modulate:a", 1, 0, 0.2, Tween.TRANS_SINE)
	_tween.start()
	
func show_squad_heal():
	_tween.interpolate_property(_frame_4, "modulate:a", 1, 0, 0.2, Tween.TRANS_SINE)
	_tween.start()

func _on_squad_icon_gui_input(event):
	_input_detection.check_input(event)

func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click", self)
