extends Node
class_name Taps

export var color :Color
var pools :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_pools()

func taps(pos :Array):
	if pos.empty():
		return
		
	for i in pos:
		var tap = _get_tap()
		
		if i is Vector3:
			tap.translation = i
			
		elif i is Squad:
			
			if is_instance_valid(i):
				tap.translation = i.move_to
			
		tap.color = color
		tap.tap()

func _create_tap() -> Tap:
	var instance :Tap = preload("res://assets/tap/tap.tscn").instance()
	add_child(instance)
	return instance

func _pools():
	for i in range(5):
		pools.append(_create_tap())
	
func _get_tap() -> Tap:
	for i in pools:
		if not i.is_visible():
			return i
			
	var i = _create_tap()
	pools.append(i)
	
	return i
