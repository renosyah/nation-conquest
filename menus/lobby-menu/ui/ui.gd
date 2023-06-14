extends Control

onready var player_holder = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/ScrollContainer/VBoxContainer
onready var host_menu_buttons = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/host_menu_buttons
onready var play_button = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/host_menu_buttons/main_menu_buttons/VBoxContainer/play
onready var add_bot = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer/add_bot
onready var bottom_offset = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/bottom_offset
onready var loading = $CanvasLayer/LobbyMenuSafeArea/VBoxContainer/HBoxContainer2/Control/loading

onready var is_server :bool = NetworkLobbyManager.is_server()

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
	
	host_menu_buttons.visible = is_server
	add_bot.disabled = not is_server
	play_button.disabled = true
	
	add_bot.icon = preload("res://assets/ui/icon/host.png") if is_server else null
	
	loading.visible = false
	
	if Admob.get_is_banner_loaded():
		Admob.show_banner()
		
	if not NetworkLobbyManager.is_server():
		rpc_id(NetworkLobbyManager.host_id, "_request_update_bot")
		
	else:
		on_lobby_player_update(NetworkLobbyManager.get_players())
	
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
		var is_host_player :bool = player.player_network_unique_id == Network.PLAYER_HOST_ID
		var is_client_player :bool = not is_host_player
		var is_local_player :bool = player.player_network_unique_id == NetworkLobbyManager.get_id()
		
		var player_data :PlayerData = PlayerData.new()
		player_data.from_dictionary(player.extra)
		
		var item = preload("res://menus/lobby-menu/item/item.tscn").instance()
		item.data = player_data
		item.is_host = is_host_player
		item.can_kick = is_server and is_client_player
		item.can_change_color = false
		item.can_change_team = is_local_player
		item.can_difficulty = false
		
		item.connect("kick", self, "_on_player_kick", [player])
		item.connect("change_team", self, "_on_player_update")
		player_holder.add_child(item)
		
		slot_count -= 1
		teams[player_data.player_team] = 1
		
	for key in bots.keys():
		if slot_count == 0:
			break
			
		var network_bot = NetworkPlayer.new()
		network_bot.from_dictionary(bots[key])
		
		var bot_data :BotPlayerData = BotPlayerData.new()
		bot_data.from_dictionary(network_bot.extra)
		
		var item = preload("res://menus/lobby-menu/item/item.tscn").instance()
		item.data = bot_data
		
		item.is_bot = true
		item.is_host = false
		item.can_kick = is_server
		item.can_change_color = is_server
		item.can_change_team = is_server
		item.can_difficulty = is_server
		
		item.connect("kick", self, "_on_bot_kick", [network_bot])
		item.connect("change_color", self, "_on_bot_update", [network_bot.player_network_unique_id])
		item.connect("change_team", self, "_on_bot_update", [network_bot.player_network_unique_id])
		item.connect("change_difficulty", self, "_on_bot_update", [network_bot.player_network_unique_id])
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
		
		item.is_host = false
		item.can_kick = false
		item.can_change_color = false
		item.can_change_team = false
		item.can_difficulty = false
		
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
	
remote func _request_update_bot():
	rpc("_update_bots", bots)
	
remotesync func _update_bots(_bots :Dictionary):
	if not NetworkLobbyManager.is_server():
		bots = _bots
		
	on_lobby_player_update(NetworkLobbyManager.get_players())
	
func _on_bot_kick(bot :NetworkPlayer):
	if NetworkLobbyManager.is_server():
		bots.erase(bot.player_network_unique_id)
		rpc("_update_bots", bots)
		
func _on_bot_update(bot :BotPlayerData, id :int):
	bots[id]["extra"] = bot.to_dictionary()
	rpc("_update_bots", bots)
	
func _on_play_pressed():
	
	rpc("_display_loading")
	
	yield(get_tree().create_timer(3), "timeout")
	
	Global.bots.clear()
	
	for key in bots:
		var network_bot = NetworkPlayer.new()
		network_bot.from_dictionary(bots[key])
		
		Global.bots.append(network_bot)
		
	NetworkLobbyManager.argument["seed"] = int(rand_range(-1000,1000))
	get_tree().change_scene("res://gameplay/mp/host/host.tscn")
	
remotesync func _display_loading():
	loading.visible = true
	host_menu_buttons.visible = false
	
func on_host_ready():
	get_tree().change_scene("res://gameplay/mp/client/client.tscn")
	
func _on_back_pressed():
	if loading.visible:
		return
		
	NetworkLobbyManager.leave()
	
func on_leave():
	get_tree().change_scene("res://menus/main-menu/main_menu.tscn")
	
	



















