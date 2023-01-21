extends Control

onready var title = $CanvasLayer/MainMenuSafeArea/VBoxContainer/HBoxContainer2/Control/Label
onready var main_menu_safe_area = $CanvasLayer/MainMenuSafeArea
onready var bottom_offset = $CanvasLayer/MainMenuSafeArea/VBoxContainer/HBoxContainer2/Control/bottom_offset

onready var server_browser = $CanvasLayer/server_browser

onready var menu = $CanvasLayer/menu
onready var tween = $Tween

var quickplay :bool = false

func _ready():
	title.modulate.a = 0
	title.visible = true
	
	main_menu_safe_area.visible = false
	server_browser.visible = false
	menu.visible = false
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	NetworkLobbyManager.connect("on_client_player_connected", self,"on_client_player_connected")
	NetworkLobbyManager.connect("on_host_player_connected", self,"on_host_player_connected")
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func show_ui():
	main_menu_safe_area.visible = true
	tween.interpolate_property(title, "modulate:a", 0, 1, 1.4,Tween.TRANS_LINEAR)
	tween.start()
	
func on_back_pressed():
	get_tree().quit()
	
func _on_quickplay_pressed():
	quickplay = true
	_on_host_pressed()
	
func _on_host_pressed():
	var configuration = NetworkServer.new()
	configuration.max_player = 4
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.player_extra_data = Global.player.to_dictionary()
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()
	
func on_host_player_connected():
	if quickplay:
		var unused_colors :Array = Utils.COLORS.duplicate()
		unused_colors.erase(Global.player.player_color)
		
		Global.bots.clear()
		
		for i in range(3):
			var bot = Global.create_bot(true, unused_colors)
			unused_colors.erase(bot.extra["player_color"])
			Global.bots.append(bot)
			
		NetworkLobbyManager.argument["seed"] = int(rand_range(-100,100))
		get_tree().change_scene("res://gameplay/mp/host/host.tscn")
		return
		
	get_tree().change_scene("res://menus/lobby-menu/lobby_menu.tscn")
	
func _on_join_pressed():
	server_browser.visible = true
	server_browser.start_finding()
	
func _on_server_browser_on_join(info):
	var configuration = NetworkClient.new()
	configuration.ip = info["ip"]
	
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.player_extra_data = Global.player.to_dictionary()
	NetworkLobbyManager.configuration = configuration
	NetworkLobbyManager.init_lobby()
	
func on_client_player_connected():
	get_tree().change_scene("res://menus/lobby-menu/lobby_menu.tscn")
	
func on_host_ready():
	get_tree().change_scene("res://gameplay/mp/client/client.tscn")

func _on_cancel_pressed():
	NetworkLobbyManager.leave()
	
func _on_setting_menu_pressed():
	menu.visible = true










