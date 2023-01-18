extends ColorRect

signal pick(_color)

onready var _input_detection = $input

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_item_gui_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		emit_signal("pick", color)
		
	_input_detection.check_input(event)
	
func _on_input_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("pick", color)
		
