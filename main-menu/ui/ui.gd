extends Control

onready var top_bar = $CanvasLayer/SafeArea
onready var title = $CanvasLayer/HBoxContainer/Control/VBoxContainer/Label

onready var control = $CanvasLayer/HBoxContainer
onready var server_browser = $CanvasLayer/server_browser
onready var main_menu_buttons = $CanvasLayer/HBoxContainer/Control/main_menu_buttons
onready var host_menu_buttons = $CanvasLayer/HBoxContainer/Control/host_menu_buttons
onready var client_menu_buttons = $CanvasLayer/HBoxContainer/Control/client_menu_buttons

onready var create_game_panel = $CanvasLayer/HBoxContainer/Control/MarginContainer/VBoxContainer
onready var player_holder = $CanvasLayer/HBoxContainer/Control/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

onready var menu = $CanvasLayer/menu
onready var tween = $Tween

var quickplay :bool = false

func _ready():
	title.modulate.a = 0
	title.visible = true
	
	control.visible = false
	server_browser.visible = false
	create_game_panel.visible = false
	main_menu_buttons.visible = true
	host_menu_buttons.visible = false
	client_menu_buttons.visible = false
	menu.visible = false
	top_bar.visible = false
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	NetworkLobbyManager.connect("on_client_player_connected", self,"on_client_player_connected")
	NetworkLobbyManager.connect("on_host_player_connected", self,"on_host_player_connected")
	NetworkLobbyManager.connect("lobby_player_update", self, "on_lobby_player_update")
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_leave")
	NetworkLobbyManager.connect("on_leave", self, "on_leave")
	NetworkLobbyManager.connect("on_kicked_by_host", self, "on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"on_host_ready")
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
	
func show_ui():
	control.visible = true
	top_bar.visible = true
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
		_on_play_pressed()
		
	title.visible = false
	create_game_panel.visible = true
	main_menu_buttons.visible = false
	host_menu_buttons.visible = true
	top_bar.visible = false
	
func _on_play_pressed():
	NetworkLobbyManager.argument["seed"] = int(rand_range(-100,100))
	get_tree().change_scene("res://gameplay/mp/host/host.tscn")
	
	
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
	title.visible = false
	create_game_panel.visible = true
	main_menu_buttons.visible = false
	client_menu_buttons.visible = true
	top_bar.visible = false
	
func on_host_ready():
	get_tree().change_scene("res://gameplay/mp/client/client.tscn")
	
func on_lobby_player_update(players :Array):
	for i in player_holder.get_children():
		player_holder.remove_child(i)
		i.queue_free()
		
	for player in players:
		var is_client :bool = player.player_network_unique_id != Network.PLAYER_HOST_ID
		var item = preload("res://main-menu/ui/item/item.tscn").instance()
		
		var player_data :PlayerData = PlayerData.new()
		player_data.from_dictionary(player.extra)
		item.data = player_data
		
		item.can_kick = NetworkLobbyManager.is_server() and is_client
		item.connect("kick", self, "_on_player_kick")
		item.connect("change_color", self, "_on_change_color")
		player_holder.add_child(item)
		
		
func _on_player_kick(player :PlayerData):
	NetworkLobbyManager.kick_player(player.player_network_unique_id)
	
func _on_change_color(player :PlayerData):
	NetworkLobbyManager.update_player_extra_data(player.to_dictionary())
	
func _on_cancel_pressed():
	NetworkLobbyManager.leave()
	host_menu_buttons.visible = false
	client_menu_buttons.visible = false
	create_game_panel.visible = false
	
func on_leave():
	title.modulate.a = 0
	title.visible = true
	
	tween.interpolate_property(title, "modulate:a", 0, 1, 1.4,Tween.TRANS_LINEAR)
	tween.start()
	
	main_menu_buttons.visible = true
	host_menu_buttons.visible = false
	client_menu_buttons.visible = false
	create_game_panel.visible = false
	top_bar.visible = true
	
func _on_setting_menu_pressed():
	menu.visible = true










