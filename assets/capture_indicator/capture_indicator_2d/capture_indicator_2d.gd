extends MarginContainer

onready var circle_bar = $circle_bar

# Called when the node enters the scene tree for the first time.
func _ready():
	circle_bar.value = 0
	circle_bar.max_value = 1
	
func set_color(_color :Color):
	circle_bar.tint_progress = _color
	circle_bar.tint_progress.a = 0.75
	
func update_bar(value, max_value : int):
	circle_bar.value = value
	circle_bar.max_value = max_value
