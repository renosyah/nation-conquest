extends Node

const host_id = 1

# broadcast signal with data
# array of network player
signal lobby_player_update(players)
signal all_player_ready

# handy signal to handle
# action in lobby
signal on_host_player_connected
signal on_client_player_connected
signal on_player_disconnected(network_player)
signal on_host_disconnected
signal connection_closed
signal on_kicked_by_host
signal on_leave

# handy signal to handle
# action in pre game
signal on_host_ready

var player_name :String = ""
var player_extra_data :Dictionary = {}
var configuration :NetworkConfiguration
var argument :Dictionary = {}

# array of player joined in lobby
# in dictionary format
var _network_player :NetworkPlayer = NetworkPlayer.new()
var _lobby_players :Array = []
var _server_advertiser :ServerAdvertiser

var _is_ready :bool = false

onready var _network :Node = get_node_or_null("/root/Network")

# call to initiate lobby
func init_lobby():
	_lobby_players.clear()
	_is_ready = false
	
	if _is_any_params_null():
		return
		
	_network_player.player_name = player_name
	_network_player.player_status = NetworkPlayer.PLAYER_STATUS_NOT_READY
	_network_player.extra = player_extra_data
	
	if configuration is NetworkServer:
		_init_host()
	elif configuration is NetworkClient:
		_init_join()
		
# call if host player ready
# to send message in lobby
# game is about to start
func set_host_ready():
	if not is_server():
		return
		
	_server_advertiser.dismantle()
	rpc("_on_host_ready", argument)
	
# call if player ready
func set_ready():
	if _is_any_params_null():
		return
		
	if not is_network_on():
		return
		
	_network_player.player_status = NetworkPlayer.PLAYER_STATUS_READY
		
	rpc("_request_update_player_joined_status",
			_network_player.player_network_unique_id, _network_player.to_dictionary())
		
func update_player_extra_data(extra :Dictionary):
	player_extra_data = extra
	
	if not is_network_on():
		return
	
	if is_server():
		_request_update_player_extra_data(
			_network_player.player_network_unique_id, player_extra_data)
	else:
		rpc_id(host_id, "_request_update_player_extra_data",
			 _network_player.player_network_unique_id, player_extra_data)
	
# get current player in lobby
func get_players() -> Array:
	var players :Array = []
	for i in _lobby_players:
		var player = NetworkPlayer.new()
		player.from_dictionary(i)
		players.append(player)
		
	return players
	
# kick player from lobby 
# can only perform by host
func kick_player(player_network_unique_id :int):
	if not is_server():
		return
		
	rpc("_kick_player", player_network_unique_id)
	
# player leave from lobby 
# can be perform by anyone
func leave():
	if is_server():
		_server_advertiser.dismantle()
	
	_network.disconnect_from_server()
	_lobby_players.clear()
	argument.clear()
	
	emit_signal("lobby_player_update", get_players())
	emit_signal("on_leave")
	
# get current player network id
func get_id() -> int:
	return _network_player.player_network_unique_id
	
################################################################
func _ready():
	_init_connection_watcher()
	
	_server_advertiser = preload("res://addons/LANServerBroadcast/server_advertiser/server_advertiser.tscn").instance()
	add_child(_server_advertiser)
	
################################################################
# host player section
func _init_host():
	var _configuration :NetworkServer = configuration as NetworkServer
	var err = _network.create_server(_configuration.max_player, _configuration.port)
	if err != OK:
		return
		
func _server_player_connected(_player_network_unique_id : int):
	_network_player.player_network_unique_id = _player_network_unique_id
	
	_server_advertiser.setup()
	_server_advertiser.serverInfo["name"] = _network_player.player_name
	_server_advertiser.serverInfo["port"] = configuration.port
	_server_advertiser.serverInfo["public"] = true
	_server_advertiser.serverInfo["player"] = _lobby_players.size()
	_server_advertiser.serverInfo["max_player"] = configuration.max_player
	
	_request_append_player_joined(_player_network_unique_id, _network_player.to_dictionary())
	emit_signal("on_host_player_connected")
	
################################################################
# join player section
func _init_join():
	var _configuration :NetworkClient = configuration as NetworkClient
	var err = _network.connect_to_server(_configuration.ip, _configuration.port)
	if err != OK:
		return
		
func _client_player_connected(_player_network_unique_id : int):
	_network_player.player_network_unique_id = _player_network_unique_id
	rpc_id(host_id, "_request_append_player_joined", _player_network_unique_id, _network_player.to_dictionary())
	emit_signal("on_client_player_connected")
	
################################################################
# lobby rpc function
remote func _request_append_player_joined(_player_network_unique_id :int, data :Dictionary):
	for i in _lobby_players:
		if i["player_network_unique_id"] == _player_network_unique_id:
			_lobby_players.erase(i)
			break
			
	_lobby_players.append(data)
	_server_advertiser.serverInfo["player"] = _lobby_players.size()
	
	rpc("_update_player_joined", _lobby_players)
	
remote func _request_update_player_extra_data(_player_network_unique_id :int, _extra :Dictionary):
	for i in _lobby_players:
		if i["player_network_unique_id"] == _player_network_unique_id:
			i["extra"] = _extra
			break
			
	rpc("_update_player_joined", _lobby_players)
	
remotesync func _request_update_player_joined_status(_player_network_unique_id :int, data : Dictionary):
	for i in _lobby_players:
		if i["player_network_unique_id"] == _player_network_unique_id:
			i["player_status"] = data["player_status"] 
			break
	
	for i in _lobby_players:
		if i["player_status"] != NetworkPlayer.PLAYER_STATUS_READY:
			return
			
	if _is_ready:
		return
		
	_is_ready = true
	
	emit_signal("all_player_ready")
	
remotesync func _update_player_joined(data : Array):
	if not is_server():
		_lobby_players = data
		
	_lobby_players.sort_custom(_CustomSorter, "sort")
	
	emit_signal("lobby_player_update", get_players())
	
remotesync func _kick_player(_player_network_unique_id :int):
	for i in _lobby_players:
		if i["player_network_unique_id"] == _player_network_unique_id:
			_lobby_players.erase(i)
			break
			
	if _network_player.player_network_unique_id == _player_network_unique_id:
		_network.disconnect_from_server()
		emit_signal("on_kicked_by_host")
		return
		
	emit_signal("lobby_player_update", get_players())
	
remotesync func _on_host_ready(data :Dictionary):
	_is_ready = false
	
	if is_server():
		return
		
	argument = data
	emit_signal("on_host_ready")
	
################################################################
# network connection watcher
# for both client and host
func _init_connection_watcher():
	_network.connect("client_player_connected", self , "_client_player_connected")
	_network.connect("server_player_connected", self ,"_server_player_connected")
	
	_network.connect("server_disconnected", self , "_server_disconnected")
	_network.connect("connection_closed", self , "_connection_closed")
	_network.connect("player_disconnected", self, "_on_player_disconnected")
	
func _on_player_disconnected(_player_network_unique_id : int):
	var _disconnected_player_network :NetworkPlayer = NetworkPlayer.new()
	for i in _lobby_players:
		if i["player_network_unique_id"] == _player_network_unique_id:
			_disconnected_player_network.from_dictionary(i)
			emit_signal("on_player_disconnected", _disconnected_player_network)
			break
			
	if is_server():
		for i in _lobby_players:
			if i["player_network_unique_id"] == _player_network_unique_id:
				_lobby_players.erase(i)
				break
				
		_server_advertiser.serverInfo["player"] = _lobby_players.size()
		rpc("_update_player_joined", _lobby_players)
	
func _server_disconnected():
	configuration = null
	_lobby_players.clear()
	emit_signal("lobby_player_update", get_players())
	emit_signal("on_host_disconnected")
	
func _connection_closed():
	configuration = null
	_lobby_players.clear()
	emit_signal("lobby_player_update", get_players())
	emit_signal("connection_closed")
	
################################################################
# utils
class _CustomSorter:
	static func sort(a, b):
		if a["player_network_unique_id"] < b["player_network_unique_id"]:
			return true
		return false
		
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
	
func _is_any_params_null() -> bool:
	var checks = [
		is_instance_valid(_network),
		is_instance_valid(configuration),
		is_instance_valid(_network_player)
	]
	return (false in checks)
	
