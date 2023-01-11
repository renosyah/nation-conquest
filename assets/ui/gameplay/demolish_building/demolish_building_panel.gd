extends Control

signal demolish

func _on_yes_pressed():
	visible = false
	emit_signal("demolish")

func _on_no_pressed():
	visible = false
