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

onready var open_building = $CanvasLayer/SafeArea/Control/HBoxContainer2/VBoxContainer/open_building
onready var building_panel = $CanvasLayer/SafeArea/building_panel

onready var demolish_building_panel = $CanvasLayer/SafeArea/demolish_building_panel
onready var repair_building_panel = $CanvasLayer/SafeArea/repair_building_panel
onready var info_panel = $CanvasLayer/SafeArea/info_panel

onready var select_all = $CanvasLayer/SafeArea/Control/HBoxContainer2/VBoxContainer/select_all
onready var unselect_all = $CanvasLayer/SafeArea/Control/HBoxContainer2/VBoxContainer/unselect_all
onready var squad_info = $CanvasLayer/SafeArea/Control/HBoxContainer2/VBoxContainer/VBoxContainer

onready var player_coin_ui = $CanvasLayer/SafeArea/Control/HBoxContainer/MarginContainer/coin/HBoxContainer/player_coin
onready var player_building = $CanvasLayer/SafeArea/Control/HBoxContainer/MarginContainer/building/HBoxContainer/player_building

onready var menu = $CanvasLayer/menu
onready var result = $CanvasLayer/result

# player squad s
# {_instance_squad : _instance_icon}
var squads = {}

# player buildings
# [_instance_building]
var buildings = []
var building_rotation :float = 0
var building_deploying :BuildingData

var player_coin :int = 1000
var player_team :int = 1

onready var player_id :int = NetworkLobbyManager.get_id()
onready var player_max_squad :int = 5
onready var player_max_building :int = 10

var selected_building :BaseBuilding = null

func _ready():
	control.visible = true
	
	add_squad.visible = false
	
	build_menu.visible = false
	squad_menu.visible = true
	
	recruit_squad_panel.visible = false
	building_panel.visible = false
	info_panel.visible = false
	
	menu.visible = false
	safe_area.visible = false
	loading.visible = true
	
	demolish_building_panel.visible = false
	repair_building_panel.visible = false
	
	select_all.visible = true
	unselect_all.visible = false
	squad_info.visible = false
	
	mini_map.set_enable(false)
	_update_player_building(false)
	_update_player_coin()
	
	
func loading(_show :bool):
	.loading(_show)
	safe_area.visible = not _show
	loading.visible = _show
	
func _on_recruit_squad_on_recruit_squad(_squad_data :SquadData):
	if player_coin - _squad_data.price < 0:
		return
		
	player_coin -= _squad_data.price
	_update_player_coin()
	
	emit_signal("recruit_squad", _squad_data)
	
func _on_building_panel_on_construct_building(_building_data :BuildingData):
	building_deploying = _building_data
	
	build_menu.visible = true
	building_panel.visible = false
	squad_menu.visible = false
	
	emit_signal("deploy_building", _building_data)
	
func _process(delta):
	var value = -45 if rotate_l.pressed else 45 if rotate_r.pressed else 0
	building_rotation += value * delta
	
	mini_map.set_zoom(get_camera_zoom())
	
func on_building_deplyoing(_building :BaseBuilding):
	if not is_player_building(_building):
		return
		
	if not buildings.has(_building):
		buildings.append(_building)
	
	open_building.visible = not is_building_max()
	
	_update_player_building(true)
	
func on_building_repair(_building :BaseBuilding):
	selected_building = _building
	repair_building_panel.set_repair_cost(selected_building.get_repair_price())
	repair_building_panel.visible = true
	
func on_building_demolish(_building :BaseBuilding):
	selected_building = _building
	demolish_building_panel.visible = true
	
func on_building_info(_building :BaseBuilding):
	info_panel.set_info(
		_building.building_name, 
		_building.building_description, 
		_building.building_icon
	)
	info_panel.visible = true
	
func on_squad_info(_squad :Squad):
	info_panel.set_info(
		_squad.squad_name, 
		_squad.squad_description, 
		_squad.squad_icon
	)
	info_panel.visible = true
	
func on_building_deployed(_building :BaseBuilding):
	if _building is TownCenter:
		add_minimap_object(
			_building.get_path(), 
			_building.color, 
			preload("res://assets/ui/icon/map_icon/town_icon.png")
		)
		
	elif _building is ArcherTower:
		add_minimap_object(
			_building.get_path(), 
			_building.color, 
			preload("res://assets/ui/icon/map_icon/tower.png")
		)
	
	if not is_player_building(_building):
		return
		
	if not buildings.has(_building):
		buildings.append(_building)
		
	if _building is Farm:
		_building.connect("harvest_time", self,"on_harvest_time")
	
	open_building.visible = not is_building_max()
	add_squad.visible = not is_squad_max() and is_player_have_town_center()
	mini_map.set_enable(is_player_have_tower() and is_player_have_town_center())
	
	_update_player_building(false)
	
func on_building_destroyed(_building :BaseBuilding):
	if not is_player_building(_building):
		return
		
	if not buildings.has(_building):
		return
		
	buildings.erase(_building)
	
	open_building.visible = not is_building_max()
	add_squad.visible = not is_squad_max() and is_player_have_town_center()
	mini_map.set_enable(is_player_have_tower() and is_player_have_town_center())
	
	_update_player_building(false)
	
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
	
	add_squad.visible = not is_squad_max() and is_player_have_town_center()
	
func _on_squad_icon_click(_icon :SquadIcon, _squad :Squad):
	_squad.emit_signal("squad_selected", _squad)
	
func on_squad_unit_added(_squad :Squad):
	if not is_player_squad(_squad):
		return
		
	if not squads.has(_squad):
		return
		
	squads[_squad].update_unit_size(_squad.unit_size())
	squads[_squad].show_squad_heal()
	
func on_squad_unit_dead(_squad :Squad):
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
	
	var any_selected :bool = check_if_squad_selected()
	var one_selected :bool = check_squad_selected_count() == 1
	
	squad_info.visible = one_selected
	unselect_all.visible = any_selected
	select_all.visible = not any_selected
	
func on_squad_dead(_squad :Squad):
	if not is_player_squad(_squad):
		return
		
	if not squads.has(_squad):
		return
		
	squads[_squad].queue_free()
	squads.erase(_squad)
	
	add_squad.visible = not is_squad_max() and is_player_have_town_center()
	
func is_player_squad(_squad :Squad) -> bool:
	return _squad.player_id == player_id
	
func is_player_building(_building :BaseBuilding) -> bool:
	return _building.player_id == player_id
	
func is_enemy_squad(_squad :Squad):
	return _squad.team != player_team
	
func is_enemy_building(_building :BaseBuilding):
	return _building.team != player_team
	
func is_player_have_tower() -> bool:
	for building in buildings:
		if not is_instance_valid(building):
			continue
			
		if building is ArcherTower and building.status == BaseBuilding.status_deployed:
			return true
			
	return false
	
func is_player_have_town_center() -> bool:
	for building in buildings:
		if not is_instance_valid(building):
			continue
			
		if building is TownCenter and building.status == BaseBuilding.status_deployed:
			return true
			
	return false
	
func check_squad_selected_count() -> int:
	var count :int = 0
	for key in squads:
		if squads[key].is_selected:
			count += 1
			
	return count
	
func check_if_squad_selected() -> bool:
	return check_squad_selected_count() > 0
	
func selected_all_squad():
	for key in squads:
		if not squads[key].is_selected:
			key.emit_signal("squad_selected", key)
			
func unselected_all_squad():
	for key in squads:
		if squads[key].is_selected:
			key.emit_signal("squad_selected", key)
	
func is_squad_max() -> bool:
	var count :int = 0
	for key in squads.keys():
		if is_instance_valid(key):
			count += 1
			
	return count == player_max_squad
	
func is_building_max() -> bool:
	var count :int = 0
	for building in buildings:
		if is_instance_valid(building):
			count += 1
			
	return count == player_max_building
	
func get_camera_moving_direction() -> Vector2:
	return camera_control.get_moving_direction()
	
func get_camera_zoom() -> float:
	return camera_control.get_zoom()
	
func get_center_screen() -> Vector2:
	return get_viewport_rect().get_center()
	
func add_minimap_object(object_path :NodePath, color :Color = Color.white, _icon :Resource = preload("res://addons/mini-map/troop.png")):
	mini_map.add_object(object_path, color, _icon)
	
func on_harvest_time(_building :Farm, _amount :int):
	player_coin += _amount
	player_coin = clamp(player_coin, 0, 1000)
		
	_update_player_coin()
	
func _update_player_coin():
	player_coin_ui.text = str(player_coin)
	recruit_squad_panel.player_coin = player_coin
	building_panel.player_coin = player_coin
	
func _update_player_building(_display_only :bool = true):
	player_building.text = str(buildings.size()) + "/" + str(player_max_building)
	
	if not _display_only:
		recruit_squad_panel.player_buildings = buildings
		building_panel.player_buildings = buildings
	
func _on_main_menu_pressed():
	menu.visible = true
	
func _on_result_on_main_menu_press():
	menu.visible = true
	
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
	
	if player_coin - building_deploying.price < 0:
		return
		
	player_coin -= building_deploying.price
	_update_player_coin()
	
	building_deploying = null
	
	emit_signal("start_building")
	
func _on_build_cancel_pressed():
	build_menu.visible = false
	squad_menu.visible = true
	emit_signal("cancel_building")
	
func _on_repair_building_panel_repair():
	if not is_instance_valid(selected_building):
		return
		
	if player_coin - selected_building.get_repair_price() < 0:
		return
		
	player_coin -= selected_building.get_repair_price()
	_update_player_coin()
	
	selected_building.repair()
	
func _on_demolish_building_panel_demolish():
	if not is_instance_valid(selected_building):
		return
		
	selected_building.demolish()
	
func _on_select_all_pressed():
	selected_all_squad()
	
func _on_unselect_all_pressed():
	unselected_all_squad()

func _on_menu_on_main_menu_press():
	emit_signal("main_menu_press")

func on_player_lose():
	if result.visible:
		return
		
	result.set_condition(false)
	game_over()
	
func on_player_win():
	if result.visible:
		return
		
	result.set_condition(true)
	game_over()
	
func game_over():
	_on_build_cancel_pressed()
	unselected_all_squad()
	control.visible = false
	result.visible = true
	
func _on_squad_info_pressed():
	for key in squads:
		if squads[key].is_selected:
			on_squad_info(key)
			return


















