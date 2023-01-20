extends ColorRect

signal pick(_color)

onready var _input_detection = $input

func _on_item_gui_input(event):
	_input_detection.check_input(event)
	
func _on_input_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("pick", color)
		
