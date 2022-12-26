extends Node
class_name BaseGameplay

func _ready():
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

func load_map():
	_map = preload("res://map/spring_island/spring_map.tscn").instance()
	_map.map_seed = NetworkLobbyManager.argument["seed"]
	_map.map_size = 100
	_map.map_scale = 1
	_map.connect("on_generate_map_completed", self, "on_generate_map_completed")
	_map.connect("on_map_click", self , "on_map_click")
	add_child(_map)
	_map.generate_map()
	
func on_generate_map_completed():
	NetworkLobbyManager.set_ready()
	
func on_map_click(_pos :Vector3):
	pass
	
################################################################
# ui
var _ui :BaseUi

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	add_child(_ui)
	
################################################################
# camera
var _camera :RtsCamera

func setup_camera():
	_camera = preload("res://assets/rts-camera/rts_camera.tscn").instance()
	add_child(_camera)
	
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
# proccess
func _process(delta):
	_camera.set_moving_direction(_ui.get_camera_moving_direction())
	_camera.set_zoom(_ui.get_camera_zoom())
	
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




















