extends BaseGameplay

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)

func on_squad_selected(_squad :Squad):
	.on_squad_selected(_squad)
	
func on_squad_dead(_squad :Squad):
	.on_squad_dead(_squad)
	
