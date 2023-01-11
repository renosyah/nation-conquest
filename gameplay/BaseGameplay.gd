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
onready var _resources :Array = []

func load_map():
	_water = preload("res://map/water/water.tscn").instance()
	_water.size = 200
	add_child(_water)
	
	_map = preload("res://map/spring_island/spring_map.tscn").instance()
	_map.map_seed = NetworkLobbyManager.argument["seed"]
	_map.map_scale = 1
	_map.map_size = 200
	_map.map_height = 15
	_map.connect("on_generate_map_completed", self, "on_generate_map_completed")
	_map.connect("on_map_click", self , "on_map_click")
	add_child(_map)
	_map.generate_map()
	
func on_generate_map_completed():
	
	# [{"scene", "pos"}]
	var sync_resources :Array = []
	var resources_scenes = {
		"bush" : preload("res://entity/resources/berry_bush/berry_bush.tscn"),
		"tree" : preload("res://entity/resources/trees/trees.tscn"),
		"rock" : preload("res://entity/resources/rock/rock.tscn")
	}
		
	if is_server():
		var index :int = 0
		var map_base_spawn_positions :Array = _map.base_spawn_positions.slice(0, 3)
		map_base_spawn_positions.shuffle()
		
		for player in NetworkLobbyManager.get_players():
			_player_base_spawn_position[player.player_network_unique_id] = map_base_spawn_positions[index]
			_player_color[player.player_network_unique_id] = Color(randf(), randf(), randf(), 1)
			index += 1
			
		for _pos in _map.spawn_positions:
			var _keys = resources_scenes.keys()
			var _scene = _keys[rand_range(0, _keys.size())]
			sync_resources.append({"scene":_scene, "pos":_pos})
			
		NetworkLobbyManager.argument["sync_resources"] = sync_resources
		NetworkLobbyManager.argument["player_base_spawn_position"] = _player_base_spawn_position
		NetworkLobbyManager.argument["player_color"] = _player_color
		
	else:
		sync_resources = NetworkLobbyManager.argument["sync_resources"]
		_player_base_spawn_position = NetworkLobbyManager.argument["player_base_spawn_position"]
		_player_color = NetworkLobbyManager.argument["player_color"]
		
	# rng mus be fresh instance
	# in order to have same result
	# of generation
	var rng = RandomNumberGenerator.new()
	rng.seed = NetworkLobbyManager.argument["seed"]
		
	for sync_resource in sync_resources:
		var scene = resources_scenes[sync_resource["scene"]]
		var pos = sync_resource["pos"]
		var instance :BaseResources = scene.instance()
		instance.rng = rng
		add_child(instance)
		instance.translation = pos
		_resources.append(instance)
		
	NetworkLobbyManager.set_ready()
	
func on_map_click(_pos :Vector3):
	if _selected_squad.empty():
		return
	
	var formation = Utils.get_formation_box(
		_pos, _selected_squad.size(), 5
	)
	for i in range(_selected_squad.size()):
		if is_instance_valid(_selected_squad[i]):
			_selected_squad[i].set_move_to(formation[i], true)
	
################################################################
# ui
var _ui :BaseUi

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	_ui.connect("main_menu_press", self, "on_main_menu_press")
	_ui.connect("deploy_building", self, "on_ui_deploy_building")
	_ui.connect("start_building", self, "on_ui_start_building")
	_ui.connect("cancel_building", self, "on_ui_cancel_building")
	_ui.connect("recruit_squad", self, "on_ui_recruit_squad")
	add_child(_ui)
	
	_ui.loading(true)
	
func on_main_menu_press():
	on_exit_game_session()
	
func on_ui_recruit_squad(_squad :SquadData):
	pass
	
func on_ui_deploy_building(_building_data :BuildingData):
	on_ui_cancel_building()
	
func on_ui_start_building():
	var id = NetworkLobbyManager.get_id()
	if not _building_to_build.has(id):
		return
		
	var _build = _building_to_build[id]
	if is_instance_valid(_build):
		_build.start_building()
		_building_to_build.erase(id)
	
func on_ui_cancel_building():
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
		_ui.get_center_screen(), _all_squads + _buildings
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
var _player_base_spawn_position :Dictionary = {}
var _player_color :Dictionary = {}

func on_deploying_building(_building_data :BuildingData, _at :Vector3 = Vector3.ZERO, _autobuild :bool = false):
	rpc("_on_deploying_building", _building_data.to_dictionary(), _at, _autobuild)
	
remotesync func _on_deploying_building(_building_data_dic :Dictionary, _at :Vector3, _autobuild :bool):
	var _building_data :BuildingData = BuildingData.new()
	_building_data.from_dictionary(_building_data_dic)
	
	if _autobuild:
		_building_data.building_time = 1
		
	var _build :BaseBuilding = _building_data.spawn(self)
	_build.connect("building_selected", self, "on_building_selected")
	_build.connect("building_deployed", self, "on_building_deployed")
	_build.connect("building_destroyed", self, "on_building_destroyed")
	
	if _autobuild:
		_build.set_process(false)
		_build.translation = _at
		_build.start_building()
		return
		
	on_building_deplyoing(_build)
	
func on_building_deplyoing(_building :BaseBuilding):
	_building_to_build[_building.player_id] = _building
	_ui.on_building_deplyoing(_building)
	
func on_building_selected(_building :BaseBuilding):
	if not _selected_squad.empty():
		on_map_click(_building.global_transform.origin)
		return
		
	_ui.on_building_selected(_building)
	
func on_building_deployed(_building :BaseBuilding):
	_buildings.append(_building)
	_ui.on_building_deployed(_building)
	
func on_building_destroyed(_building :BaseBuilding):
	if not is_server():
		return
		
	rpc("_on_building_destroyed", _building.get_path())
	
remotesync func _on_building_destroyed(_building_path :NodePath):
	var _building :BaseBuilding = get_node_or_null(_building_path)
	if not is_instance_valid(_building):
		return
		
	if _buildings.has(_building):
		_buildings.erase(_building)
		
	_ui.on_building_destroyed(_building)
	_building.queue_free()
	
################################################################
onready var _all_squads :Array = []
onready var _selected_squad :Array = []

# squad spawner
func spawn_squad(_squad :SquadData):
	rpc("_spawn_squad", _squad.to_dictionary())

remotesync func _spawn_squad(_squad_data :Dictionary):
	var _squad = SquadData.new()
	_squad.from_dictionary(_squad_data)
	
	# players own squad
	_squad.is_selectable = (_squad_data.player_id == NetworkLobbyManager.get_id())
	
	var _squad_spawn = _squad.spawn(self)
	_squad_spawn.connect("squad_update", self, "on_squad_update")
	_squad_spawn.connect("squad_selected", self,"on_squad_selected")
	_squad_spawn.connect("squad_dead", self, "on_squad_dead")
	_squad_spawn.translation = _squad.position
	
	on_squad_spawn(_squad_spawn, _squad.icon)
	
func on_squad_spawn(_squad :Squad, _icon :Resource):
	_all_squads.append(_squad)
	_ui.on_squad_spawn(_squad, _icon)
	
func on_squad_update(_squad :Squad):
	_ui.on_squad_update(_squad)
	
func on_squad_selected(_squad :Squad):
	if not _ui.is_player_squad(_squad):
		return
		
	var is_in_squad = _selected_squad.has(_squad)
	if is_in_squad:
		_squad.set_selected(false)
		_ui.on_squad_selected(_squad, false)
		_selected_squad.erase(_squad)
	else:
		_squad.set_selected(true)
		_ui.on_squad_selected(_squad, true)
		_selected_squad.append(_squad)
	
func on_squad_dead(_squad :Squad):
	if not is_server():
		return
		
	rpc("_on_squad_dead", _squad.get_path())
	
remotesync func _on_squad_dead(_squad_path :NodePath):
	var _squad :Squad = get_node_or_null(_squad_path)
	if not is_instance_valid(_squad):
		return
		
	if _all_squads.has(_squad):
		_all_squads.erase(_squad)
		
	if _selected_squad.has(_squad):
		_selected_squad.erase(_squad)
		
	_ui.on_squad_dead(_squad)
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




















