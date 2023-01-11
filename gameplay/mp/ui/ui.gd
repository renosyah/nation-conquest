extends BaseUi

signal main_menu_press

signal recruit_squad(_squad, _icon)
signal deploy_building(_building)
signal start_building
signal cancel_building

onready var loading = $CanvasLayer/loading
onready var safe_area = $CanvasLayer/SafeArea

onready var mini_map = $CanvasLayer/SafeArea/Control/HBoxContainer/MiniMap
onready var camera_control = $CanvasLayer/SafeArea/camera_control
onready var squad_icon_holder = $CanvasLayer/SafeArea/Control/squad_menu/HBoxContainer2/HBoxContainer3

onready var control = $CanvasLayer/SafeArea/Control

onready var build_confirm = $CanvasLayer/SafeArea/Control/build_menu/HBoxContainer2/build_confirm
onready var build_menu = $CanvasLayer/SafeArea/Control/build_menu

onready var squad_menu = $CanvasLayer/SafeArea/Control/squad_menu
onready var add_squad = $CanvasLayer/SafeArea/Control/squad_menu/HBoxContainer2/add_squad

onready var rotate_l = $CanvasLayer/SafeArea/Control/build_menu/HBoxContainer/rotate_l
onready var rotate_r = $CanvasLayer/SafeArea/Control/build_menu/HBoxContainer/rotate_r

onready var recruit_squad_panel = $CanvasLayer/SafeArea/recruit_squad

onready var open_building = $CanvasLayer/SafeArea/Control/HBoxContainer2/open_building
onready var building_panel = $CanvasLayer/SafeArea/building_panel

onready var demolish_building_panel = $CanvasLayer/SafeArea/demolish_building_panel

# player squad s
# {_instance_squad : _instance_icon}
var squads = {}

# player buildings
# [_instance_building]
var buildings = []
var building_rotation :float = 0

onready var player_id :int = NetworkLobbyManager.get_id()
onready var player_max_squad :int = 5
onready var player_max_building :int = 8

var selected_building :BaseBuilding = null

func _ready():
	control.visible = true
	
	build_menu.visible = false
	squad_menu.visible = true
	
	recruit_squad_panel.visible = false
	building_panel.visible = false
	
	safe_area.visible = false
	loading.visible = true
	
	demolish_building_panel.visible = false
	
func loading(_show :bool):
	.loading(_show)
	safe_area.visible = not _show
	loading.visible = _show
	
func _on_recruit_squad_on_recruit_squad(_squad_data :SquadData):
	emit_signal("recruit_squad", _squad_data)
	
func _on_building_panel_on_construct_building(_building_data :BuildingData):
	build_menu.visible = true
	building_panel.visible = false
	squad_menu.visible = false
	
	emit_signal("deploy_building", _building_data)
	
func _process(delta):
	var value = -45 if rotate_l.pressed else 45 if rotate_r.pressed else 0
	building_rotation += value * delta
	
func on_building_deplyoing(_building :BaseBuilding):
	if not is_player_building(_building):
		return
		
	if not buildings.has(_building):
		buildings.append(_building)
	
	open_building.visible = buildings.size() < player_max_building
	
func on_building_selected(_building :BaseBuilding):
	if not is_player_building(_building):
		return
		
	selected_building = _building
	demolish_building_panel.visible = true
	
func on_building_deployed(_building :BaseBuilding):
	var tower_icon = preload("res://entity/building/archer_tower/tower.png")
	add_minimap_object(_building.get_path(), _building.color, tower_icon)
	
	if not is_player_building(_building):
		return
		
	if not buildings.has(_building):
		buildings.append(_building)
	
	open_building.visible = buildings.size() < player_max_building
	
func on_building_destroyed(_building :BaseBuilding):
	if not is_player_building(_building):
		return
		
	if not buildings.has(_building):
		return
		
	buildings.erase(_building)
	
	open_building.visible = buildings.size() < player_max_building
	
func on_squad_spawn(_squad :Squad, _icon :Resource):
	add_minimap_object(_squad.get_path(), _squad.color)
	
	if not is_player_squad(_squad):
		return
		
	var instance :SquadIcon = preload("res://assets/ui/icon/squad_icon/squad_icon.tscn").instance()
	instance.icon = _icon
	instance.title = str(_squad.max_unit)
	instance.color = _squad.color
	instance.connect("on_click", self , "_on_squad_icon_click", [_squad])
	squad_icon_holder.add_child(instance)
	squads[_squad] = instance
	
	add_squad.visible = squads.size() < player_max_squad
	
func _on_squad_icon_click(_icon :SquadIcon, _squad :Squad):
	_squad.emit_signal("squad_selected", _squad)
	
func on_squad_update(_squad :Squad):
	if not is_player_squad(_squad):
		return
		
	if not squads.has(_squad):
		return
		
	squads[_squad].update_unit_size(_squad.unit_size())
	squads[_squad].show_squad_hurt()
	
func on_squad_selected(_squad :Squad, is_selected :bool):
	if not is_player_squad(_squad):
		return
		
	if not squads.has(_squad):
		return
		
	squads[_squad].set_selected(is_selected)
	
func on_squad_dead(_squad :Squad):
	if not is_player_squad(_squad):
		return
		
	if not squads.has(_squad):
		return
		
	squads[_squad].queue_free()
	squads.erase(_squad)
	
	add_squad.visible = squads.size() < player_max_squad
	
func is_player_squad(_squad :Squad) -> bool:
	return _squad.player_id == NetworkLobbyManager.get_id()
	
func is_player_building(_building :BaseBuilding) -> bool:
	return _building.player_id == NetworkLobbyManager.get_id()
	
func get_camera_moving_direction() -> Vector2:
	return camera_control.get_moving_direction()
	
func get_camera_zoom() -> float:
	return camera_control.get_zoom()
	
func get_center_screen() -> Vector2:
	return get_viewport_rect().get_center()
	
func add_minimap_object(object_path :NodePath, color :Color = Color.white, _icon :Resource = preload("res://addons/mini-map/troop.png")):
	mini_map.add_object(object_path, color, _icon)
	
func _on_main_menu_pressed():
	emit_signal("main_menu_press")

func _on_add_squad_pressed():
	recruit_squad_panel.display_squad_recruitment()
	recruit_squad_panel.visible = true
	
func _on_open_building_pressed():
	building_panel.display_building_panel()
	building_panel.visible = true
	
func can_build(val :bool):
	build_confirm.disabled = not val

func _on_build_confirm_pressed():
	build_menu.visible = false
	squad_menu.visible = true
	emit_signal("start_building")
	
func _on_build_cancel_pressed():
	build_menu.visible = false
	squad_menu.visible = true
	emit_signal("cancel_building")

func _on_demolish_building_panel_demolish():
	if not is_instance_valid(selected_building):
		return
		
	selected_building.demolish()

















