extends Control

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	#NetworkLobbyManager.connect("on_client_player_connected", self,"on_client_player_connected")
	NetworkLobbyManager.connect("on_host_player_connected", self,"on_host_player_connected")
	#NetworkLobbyManager.connect("lobby_player_update", self, "on_lobby_player_update")
	#NetworkLobbyManager.connect("on_host_disconnected", self, "on_leave")
	#NetworkLobbyManager.connect("on_leave", self, "on_leave")
	#NetworkLobbyManager.connect("on_host_ready", self ,"on_host_ready")
	
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
	
func _on_play_pressed():
	var configuration = NetworkServer.new()
	configuration.max_player = 4
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()
	
func on_host_player_connected():
	NetworkLobbyManager.argument["seed"] = 1
	NetworkLobbyManager.set_host_ready()
	get_tree().change_scene("res://gameplay/mp/host/host.tscn")
