extends BaseGameplay

var selected_squad :Squad

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)
	
	if not is_instance_valid(selected_squad):
		return
		
	selected_squad.is_moving = true
	selected_squad.move_to = _pos
	
	_tap.translation = _pos
	_tap.tap()

func on_squad_selected(_squad :Squad):
	.on_squad_selected(_squad)
	
	if is_instance_valid(selected_squad):
		selected_squad.set_selected(false)
		
	selected_squad = _squad
	selected_squad.set_selected(true)
