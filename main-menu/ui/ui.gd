extends Control

onready var server_browser = $CanvasLayer/Control/server_browser
onready var main_menu_buttons = $CanvasLayer/Control/main_menu_buttons
onready var host_menu_buttons = $CanvasLayer/Control/host_menu_buttons

func _ready():
	server_browser.visible = false
	main_menu_buttons.visible = true
	host_menu_buttons.visible = false
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	NetworkLobbyManager.connect("on_client_player_connected", self,"on_client_player_connected")
	NetworkLobbyManager.connect("on_host_player_connected", self,"on_host_player_connected")
	#NetworkLobbyManager.connect("lobby_player_update", self, "on_lobby_player_update")
	#NetworkLobbyManager.connect("on_host_disconnected", self, "on_leave")
	#NetworkLobbyManager.connect("on_leave", self, "on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"on_host_ready")
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	get_tree().quit()
	
func on_host_player_connected():
	main_menu_buttons.visible = false
	host_menu_buttons.visible = true
	
func _on_play_pressed():
	NetworkLobbyManager.argument["seed"] = int(rand_range(-100,100))
	get_tree().change_scene("res://gameplay/mp/host/host.tscn")
	
func _on_host_pressed():
	var configuration = NetworkServer.new()
	configuration.max_player = 4
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()

func _on_join_pressed():
	server_browser.visible = true
	server_browser.start_finding()
	
func _on_server_browser_on_join(info):
	var configuration = NetworkClient.new()
	configuration.ip = info["ip"]
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()
	
func on_client_player_connected():
	main_menu_buttons.visible = false
	host_menu_buttons.visible = false
	
func on_host_ready():
	get_tree().change_scene("res://gameplay/mp/client/client.tscn")
	
	
	
	
	
