extends BaseUi

signal main_menu_press

signal recruit_squad(_squad, _icon)
signal deploy_building(_building)
signal start_building
signal cancel_building

const squad_icon_scene = preload("res://assets/ui/icon/squad_icon/squad_icon.tscn")

onready var mini_map = $CanvasLayer/SafeArea/minimap_panel/MiniMap
onready var camera_control = $CanvasLayer/SafeArea/camera_control
onready var squad_icon_holder = $CanvasLayer/SafeArea/Control/squad_menu/HBoxContainer2/HBoxContainer3

onready var minimap_panel = $CanvasLayer/SafeArea/minimap_panel
onready var control = $CanvasLayer/SafeArea/Control

onready var build_confirm = $CanvasLayer/SafeArea/Control/build_menu/HBoxContainer2/build_confirm
onready var build_menu = $CanvasLayer/SafeArea/Control/build_menu

onready var squad_menu = $CanvasLayer/SafeArea/Control/squad_menu
onready var add_squad = $CanvasLayer/SafeArea/Control/squad_menu/HBoxContainer2/add_squad

onready var rotate_l = $CanvasLayer/SafeArea/Control/build_menu/HBoxContainer/rotate_l
onready var rotate_r = $CanvasLayer/SafeArea/Control/build_menu/HBoxContainer/rotate_r

onready var recruit_squad = $CanvasLayer/SafeArea/recruit_squad
onready var recruit_squad_icon_holder = $CanvasLayer/SafeArea/recruit_squad/HBoxContainer2/Panel/VBoxContainer/ScrollContainer/HBoxContainer3

var squads = {}
var building_rotation :float = 0

func _ready():
	minimap_panel.visible = false
	control.visible = true
	
	build_menu.visible = false
	squad_menu.visible = true
	
	recruit_squad.visible = false
	
func _display_squad_recruitment():
	for i in recruit_squad_icon_holder.get_children():
		recruit_squad_icon_holder.remove_child(i)
		i.queue_free()
		
	var squad_datas = [
		preload("res://data/squad_data/squads/militia_squad.tres"),
		preload("res://data/squad_data/squads/spearman_squad.tres"),
		preload("res://data/squad_data/squads/archer_squad.tres"),
		preload("res://data/squad_data/squads/axeman_squad.tres"),
		preload("res://data/squad_data/squads/swordman_squad.tres"),
		preload("res://data/squad_data/squads/pikeman_squad.tres"),
		preload("res://data/squad_data/squads/crossbowman_squad.tres"),
		preload("res://data/squad_data/squads/maceman_squad.tres"),
	]

	var squad_icons = [
		preload("res://assets/ui/icon/squad_icon/icon_squad_man_at_arms.png"),
		preload("res://assets/ui/icon/squad_icon/icon_squad_spearman.png"),
		preload("res://assets/ui/icon/squad_icon/icon_squad_archer.png"),
		preload("res://assets/ui/icon/squad_icon/icon_squad_axeman.png"),
		preload("res://assets/ui/icon/squad_icon/icon_squad_swordman.png"),
		preload("res://assets/ui/icon/squad_icon/icon_squad_pikeman.png"),
		preload("res://assets/ui/icon/squad_icon/icon_squad_crossbowman.png"),
		preload("res://assets/ui/icon/squad_icon/icon_squad_maceman.png"),
	]
	
	for i in range(squad_datas.size()):
		var instance :SquadIcon = squad_icon_scene.instance()
		instance.icon = squad_icons[i]
		instance.squad = null
		instance.unit_size = squad_datas[i].max_unit
		instance.color = Color.gray
		instance.connect("on_click", self , "_on_recruit_squad_icon_click", [squad_datas[i]])
		recruit_squad_icon_holder.add_child(instance)
		
func _on_recruit_squad_icon_click(_icon :SquadIcon, _squad :Squad, _squad_data :SquadData):
	_on_close_recruit_squad_pressed()
	emit_signal("recruit_squad", _squad_data, _icon.icon)
	
func _process(delta):
	var value = -45 if rotate_l.pressed else 45 if rotate_r.pressed else 0
	building_rotation += value * delta
	
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
	
	add_squad.visible = squads.size() < 4
	
func _on_squad_icon_click(_icon :SquadIcon, _squad :Squad):
	_squad.emit_signal("squad_selected", _squad)
	
func on_squad_update(_squad :Squad):
	if not squads.has(_squad):
		return
		
	squads[_squad].update_unit_size(_squad.unit_size())
	squads[_squad].show_squad_hurt()
	
func on_squad_selected(_squad :Squad, is_selected :bool):
	if not squads.has(_squad):
		return
		
	squads[_squad].set_selected(is_selected)
	
func on_squad_dead(_squad :Squad):
	if not squads.has(_squad):
		return
		
	squads[_squad].queue_free()
	squads.erase(_squad)
	
	add_squad.visible = squads.size() < 4
	
func get_camera_moving_direction() -> Vector2:
	return camera_control.get_moving_direction()
	
func get_camera_zoom() -> float:
	return camera_control.get_zoom()
	
func get_center_screen() -> Vector2:
	return get_viewport_rect().get_center()
	
func add_minimap_object(object_path :NodePath, color :Color = Color.white, _icon :Resource = preload("res://addons/mini-map/troop.png")):
	mini_map.add_object(object_path, color, _icon)

func _on_open_minimap_pressed():
	minimap_panel.visible = true
	control.visible = false
	
func _on_close_minimap_pressed():
	minimap_panel.visible = false
	control.visible = true

func _on_main_menu_pressed():
	emit_signal("main_menu_press")

func _on_add_squad_pressed():
	_display_squad_recruitment()
	recruit_squad.visible = true
	
func _on_open_building_pressed():
	build_menu.visible = true
	squad_menu.visible = false
	emit_signal("deploy_building", 
		preload("res://data/building_data/archer_tower.tres")
	)

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

func _on_close_recruit_squad_pressed():
	recruit_squad.visible = false










