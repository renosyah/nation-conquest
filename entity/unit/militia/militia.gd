extends BaseUnit

# Called when the node enters the scene tree for the first time.
func _ready():
	$pivot/body.modulate = color
	$pivot/leg_l.modulate = color 
	$pivot/leg_r.modulate = color
