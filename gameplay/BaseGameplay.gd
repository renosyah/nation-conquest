extends Node
class_name BaseGameplay

func _ready():
	randomize()
	
	set_process(false)
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	setup_ui()
	load_map()
	setup_camera()
	setup_enviroment()
	
	set_process(true)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	on_exit_game_session()
	
################################################################

var _map :BaseMap
var _water :Water

func load_map():
	_water = preload("res://map/water/water.tscn").instance()
	_water.size = 200
	add_child(_water)
	
	_map = preload("res://map/spring_island/spring_map.tscn").instance()
	_map.map_seed = NetworkLobbyManager.argument["seed"]
	_map.map_scale = 1
	_map.map_size = 200
	_map.map_height = 10
	_map.connect("on_generate_map_completed", self, "on_generate_map_completed")
	_map.connect("on_map_click", self , "on_map_click")
	add_child(_map)
	_map.generate_map()

	var rng = RandomNumberGenerator.new()
	rng.seed = NetworkLobbyManager.argument["seed"]
	
	var positions_copy = _map.spawn_positions.duplicate()
	_spawn_points = _generate_spawn_points(positions_copy)
	
	var resources_scenes = [
		preload("res://entity/resources/berry_bush/berry_bush.tscn"),
		preload("res://entity/resources/trees/trees.tscn"),
		preload("res://entity/resources/rock/rock.tscn"),
	]
	for pos in positions_copy:
		var resources =  resources_scenes[rng.randi_range(0, resources_scenes.size() - 1)].instance()
		resources.rng = rng
		add_child(resources)
		resources.translation = pos
		
func on_generate_map_completed():
	var delay = Timer.new()
	delay.wait_time = 1
	add_child(delay)
	delay.start()
	
	yield(delay, "timeout")
	delay.queue_free()
	
	NetworkLobbyManager.set_ready()
	
func on_map_click(_pos :Vector3):
	if selected_squad.empty():
		return
	
	var formation = Utils.get_formation_box(
		_pos, selected_squad.size(), 5
	)
	for i in range(selected_squad.size()):
		if is_instance_valid(selected_squad[i]):
			selected_squad[i].set_move_to(formation[i], true)
	
func _generate_spawn_points(positions_copy :Array) -> Array:
	var edges = [
		Vector3(-100, 0, -100),
		Vector3(100, 0, -100),
		Vector3(-100, 0, 100),
		Vector3(100, 0, 100),
	]
	var _spawn_points :Array = [
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
	]
	
	var index :int = 0
	for edge in edges:
		for pos in positions_copy:
			var close_1 = _spawn_points[index].distance_squared_to(edge)
			var close_2 = pos.distance_squared_to(edge)
			if close_2 < close_1 and pos.y > 2:
				_spawn_points[index] = pos
				
		positions_copy.erase(_spawn_points[index])
		index += 1
		
	for pos in positions_copy:
		if _spawn_points[4].y < pos.y:
			_spawn_points[4] = pos
			
	positions_copy.erase(_spawn_points[4])
		
	return _spawn_points
	
################################################################
# ui
var _ui :BaseUi

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	_ui.connect("main_menu_press", self, "on_main_menu_press")
	_ui.connect("deploy_building", self, "_on_ui_deploy_building")
	_ui.connect("start_building", self, "_on_ui_start_building")
	_ui.connect("cancel_building", self, "_on_ui_cancel_building")
	_ui.connect("recruit_squad", self, "_on_ui_recruit_squad")
	add_child(_ui)
	
func on_main_menu_press():
	on_exit_game_session()
	
func _on_ui_recruit_squad(_squad :SquadData):
	pass
	
func _on_ui_deploy_building(_building_data :BuildingData):
	_on_ui_cancel_building()
	
func _on_ui_start_building():
	var id = NetworkLobbyManager.get_id()
	if not _building_to_build.has(id):
		return
		
	var _build = _building_to_build[id]
	if is_instance_valid(_build):
		_build.start_building()
		_building_to_build.erase(id)
	
func _on_ui_cancel_building():
	var id = NetworkLobbyManager.get_id()
	if not _building_to_build.has(id):
		return
		
	var _build = _building_to_build[id]
	if is_instance_valid(_build):
		_build.demolish()
		_building_to_build.erase(id)
	
################################################################
# camera
var _camera :RtsCamera
var _camera_last_aim_pos :Vector3

func setup_camera():
	_camera = preload("res://assets/rts-camera/rts_camera.tscn").instance()
	add_child(_camera)
	
func update_camera_aiming_at():
	var _cam_aim :CameraAimingData = _camera.get_camera_aiming_at(
		_ui.get_center_screen(),
		squads
	)
	if _cam_aim.collider == _water:
		return
		
	_camera_last_aim_pos = _cam_aim.position
	
################################################################
# directional light
var _environment :Node

func setup_enviroment():
	_environment = preload("res://assets/enviroment/enviroment.tscn").instance()
	add_child(_environment)
	
################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_host_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "connection_closed")
	NetworkLobbyManager.connect("all_player_ready", self, "all_player_ready")
	NetworkLobbyManager.connect("on_player_disconnected", self, "on_player_disconnected")
	
func on_player_disconnected(_player_network :NetworkPlayer):
	pass
	
func connection_closed():
	get_tree().change_scene("res://main-menu/main_menu.tscn")
	
func on_host_disconnected():
	get_tree().change_scene("res://main-menu/main_menu.tscn")
	
func all_player_ready():
	_ui.loading(false)
	
################################################################
var _building_to_build :Dictionary = {}
var _buildings :Array = []
var _spawn_points :Array = []

func on_deploying_building(_building_data :BuildingData):
	rpc("_on_deploying_building", _building_data.to_dictionary())
	
remotesync func _on_deploying_building(_building_data_dic :Dictionary):
	var _building_data :BuildingData = BuildingData.new()
	_building_data.from_dictionary(_building_data_dic)
	
	_building_to_build[_building_data.network_master] = _building_data.spawn(self)
	
	var _build :BaseBuilding = _building_to_build[_building_data.network_master]
	_build.connect("building_selected", self, "on_building_selected")
	_build.connect("building_deployed", self, "on_building_deployed")
	_build.connect("building_destroyed", self, "on_building_destroyed")
	
func on_building_selected(_building :BaseBuilding):
	pass
	
func on_building_deployed(_building :BaseBuilding):
	_buildings.append(_building)
	_ui.add_minimap_object(
		_building.get_path(), 
		_building.color, 
		preload("res://entity/building/archer_tower/tower.png")
	)
	
func on_building_destroyed(_building :BaseBuilding):
	_buildings.erase(_building)
	_building.queue_free()
	
################################################################
onready var squads :Array = []
onready var selected_squad :Array = []

# squad spawner
func spawn_squad(_squad :SquadData, _at :Vector3, _parent :NodePath = get_path()):
	rpc("_spawn_squad", _squad.to_dictionary(), _at, _parent)

remotesync func _spawn_squad(_squad_data :Dictionary, _at :Vector3, _parent :NodePath):
	var _squad = SquadData.new()
	_squad.from_dictionary(_squad_data)
	
	# players own squad
	_squad.is_selectable = _squad_data.network_master == NetworkLobbyManager.get_id() and _squad.team == 1
	
	var _squad_spawn = _squad.spawn(get_node_or_null(_parent))
	_squad_spawn.connect("squad_update", self, "on_squad_update")
	_squad_spawn.connect("squad_selected", self,"on_squad_selected")
	_squad_spawn.connect("squad_dead", self, "on_squad_dead")
	_squad_spawn.translation = _at
	
	_ui.add_minimap_object(_squad_spawn.get_path(), _squad.color)
	
	on_squad_spawn(_squad_spawn, _squad.icon)
	
func on_squad_spawn(_squad :Squad, _icon :Resource):
	squads.append(_squad)
	
	if _squad.get_network_master() != NetworkLobbyManager.get_id()  or _squad.team != 1:
		return
		
	_ui.on_squad_spawn(_squad, _icon)
	
func on_squad_update(_squad :Squad):
	_ui.on_squad_update(_squad)
	
func on_squad_selected(_squad :Squad):
	if _squad.get_network_master() != NetworkLobbyManager.get_id()  or _squad.team != 1:
		return
		
	var is_in_squad = selected_squad.has(_squad)
	if is_in_squad:
		_squad.set_selected(false)
		_ui.on_squad_selected(_squad, false)
		selected_squad.erase(_squad)
	else:
		_squad.set_selected(true)
		_ui.on_squad_selected(_squad, true)
		selected_squad.append(_squad)
	
func on_squad_dead(_squad :Squad):
	if squads.has(_squad):
		squads.erase(_squad)
		
	if selected_squad.has(_squad):
		selected_squad.erase(_squad)
		
	if _squad.get_network_master() == NetworkLobbyManager.get_id() and _squad.team == 1:
		_ui.on_squad_dead(_squad)
	
	if not is_server():
		return
		
	rpc("_on_squad_dead", _squad.get_path())
	
remotesync func _on_squad_dead(_squad_path :NodePath):
	var _squad :Squad = get_node_or_null(_squad_path)
	if not is_instance_valid(_squad):
		return
		
	_squad.queue_free()
	
################################################################
# proccess
func _process(delta):
	_camera.set_moving_direction(_ui.get_camera_moving_direction() * delta)
	_camera.set_zoom(_ui.get_camera_zoom())
	
	var id = NetworkLobbyManager.get_id()
	if _building_to_build.has(id):
		var _build = _building_to_build[id]
		if is_instance_valid(_build):
			update_camera_aiming_at()
			_build.translation = _camera_last_aim_pos
			_build.rotation_degrees.y = _ui.building_rotation
			_ui.can_build(_build.can_build)
			
	
		
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
################################################################
# network utils code
func is_server():
	if not is_network_on():
		return false
		
	if not get_tree().is_network_server():
		return false
		
	return true
	
func is_network_on() -> bool:
	if not get_tree().network_peer:
		return false
		
	if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
		
	return true
	
################################################################




















