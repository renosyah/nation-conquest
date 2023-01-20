extends Control

signal on_pick(_color)

onready var _custom = $VBoxContainer/custom
onready var _pallete = $VBoxContainer/pallete

onready var _custom_btn = $VBoxContainer/PanelContainer/HBoxContainer/custom
onready var _pallete_btn = $VBoxContainer/PanelContainer/HBoxContainer/pallete

onready var _holder = $VBoxContainer/pallete/ItemList

onready var _custom_color = $VBoxContainer/custom/hbox2/item/color
onready var _R_label = $VBoxContainer/custom/R/hbox2/Label6
onready var _G_label = $VBoxContainer/custom/G/hbox2/Label6
onready var _B_label = $VBoxContainer/custom/B/hbox2/Label6

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_pallete_pressed()
	
	for i in Utils.COLORS:
		var item = preload("res://assets/ui/input-color/item/item.tscn").instance()
		item.connect("pick", self, "_on_pick")
		item.color = Color(i)
		_holder.add_child(item)
		
func _on_pick(_color):
	emit_signal("on_pick", _color)
	visible = false
	
func _on_continue_pressed():
	_on_pick(_custom_color.color)
	
func _on_back_pressed():
	visible = false
	
func _on_custom_pressed():
	_custom_btn.visible = false
	_pallete_btn.visible = not _custom_btn.visible
	
	_custom.visible = _pallete_btn.visible
	_pallete.visible = _custom_btn.visible
	
func _on_pallete_pressed():
	_custom_btn.visible = true
	_pallete_btn.visible = not _custom_btn.visible
	
	_custom.visible = _pallete_btn.visible
	_pallete.visible = _custom_btn.visible
	
func _on_R_slider_value_changed(value):
	var _color = _custom_color.color
	_color.r = value
	_custom_color.color = _color
	_R_label.text = "R : " + str(value)

func _on_G_slider_value_changed(value):
	var _color = _custom_color.color
	_color.g = value
	_custom_color.color = _color
	_G_label.text = "G : " + str(value)

func _on_B_slider_value_changed(value):
	var _color = _custom_color.color
	_color.b = value
	_custom_color.color = _color
	_B_label.text = "B : " + str(value)

















