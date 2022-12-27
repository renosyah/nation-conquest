extends "res://entity/unit/militia/militia.gd"

onready var shield = $pivot/shield

# Called when the node enters the scene tree for the first time.
func _ready():
	shield.modulate = color

