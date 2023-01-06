extends BaseUi

const squad_icon_scene = preload("res://assets/ui/icon/squad_icon/squad_icon.tscn")

onready var mini_map = $CanvasLayer/SafeArea/Control/HBoxContainer/MiniMap
onready var camera_control = $CanvasLayer/SafeArea/camera_control
onready var squad_icon_holder = $CanvasLayer/SafeArea/Control/VBoxContainer/HBoxContainer2

onready var score_ui = $CanvasLayer/SafeArea/Control/HBoxContainer/score

var score :int = 0
var squads = {}

func _ready():
	pass
	
func on_squad_spawn(_squad :Squad, _icon :Resource):
	var instance :SquadIcon = squad_icon_scene.instance()
	instance.icon = _icon
	instance.squad = _squad
	instance.unit_size = _squad.max_unit
	instance.color = _squad.color
	instance.connect("on_click", self , "_on_squad_icon_click")
	squad_icon_holder.add_child(instance)
	squads[_squad] = instance
	
	mini_map.set_color(_squad.color)
	
func _on_squad_icon_click(_icon :SquadIcon, _squad :Squad):
	_squad.emit_signal("squad_selected", _squad)
	
func on_squad_update(_squad :Squad):
	if _squad.team == 2:
		score += 1
		score_ui.text = "Score : " + str(score)
		
	if not squads.has(_squad):
		return
		
	squads[_squad].update_unit_size(_squad.unit_size())
	
func on_squad_selected(_squad :Squad, is_selected :bool):
	if not squads.has(_squad):
		return
		
	squads[_squad].set_selected(is_selected)
	
func on_squad_dead(_squad :Squad):
	if not squads.has(_squad):
		return
		
	squads[_squad].queue_free()
	squads.erase(_squad)
	
func get_camera_moving_direction() -> Vector2:
	return camera_control.get_moving_direction()
	
func get_camera_zoom() -> float:
	return camera_control.get_zoom()
	
func add_minimap_object(object_path :NodePath, color :Color = Color.white, _icon :Resource = preload("res://addons/mini-map/troop.png")):
	mini_map.add_object(object_path, color, _icon)
