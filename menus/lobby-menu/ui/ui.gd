extends Control

onready var player_holder = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/ScrollContainer/VBoxContainer
onready var host_menu_buttons = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/host_menu_buttons
onready var play_button = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/host_menu_buttons/main_menu_buttons/VBoxContainer/play

var bots :Dictionary = {}
var teams :Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	NetworkLobbyManager.connect("lobby_player_update", self, "on_lobby_player_update")
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_leave")
	NetworkLobbyManager.connect("on_leave", self, "on_leave")
	NetworkLobbyManager.connect("on_kicked_by_host", self, "on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"on_host_ready")
	
	on_lobby_player_update(NetworkLobbyManager.get_players())
	host_menu_buttons.visible = NetworkLobbyManager.is_server()
	play_button.disabled = true
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
	
func on_lobby_player_update(players :Array):
	teams.clear()
	
	for i in player_holder.get_children():
		player_holder.remove_child(i)
		i.queue_free()
		
	var slot_count :int = 4
		
	for player in players:
		var is_client :bool = player.player_network_unique_id != Network.PLAYER_HOST_ID
		var is_local_player :bool = NetworkLobbyManager.get_id() == player.player_network_unique_id
		
		var player_data :PlayerData = PlayerData.new()
		player_data.from_dictionary(player.extra)
		
		var item = preload("res://menus/lobby-menu/item/item.tscn").instance()
		item.data = player_data
		item.can_kick = NetworkLobbyManager.is_server() and is_client
		item.can_change_color = false
		item.can_change_team = is_local_player
		
		item.connect("kick", self, "_on_player_kick", [player])
		item.connect("change_team", self, "_on_player_update")
		player_holder.add_child(item)
		
		slot_count -= 1
		teams[player_data.player_team] = 1
		
	for key in bots.keys():
		var network_bot = NetworkPlayer.new()
		network_bot.from_dictionary(bots[key])
		
		var bot_data :PlayerData = PlayerData.new()
		bot_data.from_dictionary(network_bot.extra)
		
		var is_server :bool = NetworkLobbyManager.is_server()
		
		var item = preload("res://menus/lobby-menu/item/item.tscn").instance()
		item.data = bot_data
		item.can_kick = is_server
		item.can_change_color = is_server
		item.can_change_team = is_server
		
		item.connect("kick", self, "_on_bot_kick", [network_bot])
		item.connect("change_color", self, "_on_bot_update", [network_bot.player_network_unique_id])
		item.connect("change_team", self, "_on_bot_update", [network_bot.player_network_unique_id])
		player_holder.add_child(item)
		
		slot_count -= 1
		teams[bot_data.player_team] = 1
		
	for i in range(slot_count):
		var player_data :PlayerData = PlayerData.new()
		player_data.player_name = "- Empty Slot -"
		player_data.player_team = 0
		player_data.player_color = Color.black
		
		var item = preload("res://menus/lobby-menu/item/item.tscn").instance()
		item.data = player_data
		item.can_kick = false
		item.can_change_color = false
		item.can_change_team = false
		
		player_holder.add_child(item)
		
		
	# if all only one team
	# game is invalid
	play_button.disabled = (teams.size() == 1)
		
func _on_player_kick(player :NetworkPlayer):
	if NetworkLobbyManager.is_server():
		NetworkLobbyManager.kick_player(player.player_network_unique_id)
	
func _on_player_update(player :PlayerData):
	NetworkLobbyManager.update_player_extra_data(player.to_dictionary())
	
func _on_add_bot_pressed():
	if not NetworkLobbyManager.is_server():
		return
		
	if bots.size() + NetworkLobbyManager.get_players().size() >= 4:
		return
		
	var network_bot = Global.create_bot()
	bots[network_bot.player_network_unique_id] = network_bot.to_dictionary()
	
	rpc("_update_bots", bots)

remotesync func _update_bots(_bots :Dictionary):
	if not NetworkLobbyManager.is_server():
		bots = _bots
		
	on_lobby_player_update(NetworkLobbyManager.get_players())
	
func _on_bot_kick(bot :NetworkPlayer):
	if NetworkLobbyManager.is_server():
		bots.erase(bot.player_network_unique_id)
		rpc("_update_bots", bots)
		
func _on_bot_update(bot :PlayerData, id :int):
	bots[id]["extra"] = bot.to_dictionary()
	rpc("_update_bots", bots)
	
func _on_play_pressed():
	Global.bots.clear()
	
	for key in bots:
		var network_bot = NetworkPlayer.new()
		network_bot.from_dictionary(bots[key])
		
		Global.bots.append(network_bot)
		
	NetworkLobbyManager.argument["seed"] = int(rand_range(-100,100))
	get_tree().change_scene("res://gameplay/mp/host/host.tscn")
	
func on_host_ready():
	get_tree().change_scene("res://gameplay/mp/client/client.tscn")
	
func _on_back_pressed():
	NetworkLobbyManager.leave()
	
func on_leave():
	get_tree().change_scene("res://menus/main-menu/main_menu.tscn")
	
	


















