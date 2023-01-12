extends Node

const ping_interval = 1.0
const ping_increment = 0.06

const DEFAULT_IP : String = '127.0.0.1'
const DEFAULT_PORT : int = 31400
const MAX_PLAYERS : int = 5
const PLAYER_HOST_ID : int = 1
const LATENCY_TWEEN = 0.10
const LATENCY_DELAY = 0.08

signal server_player_connected(player_network_unique_id)
signal client_player_connected(player_network_unique_id)
signal player_connected(player_network_unique_id)
signal player_disconnected(player_network_unique_id)
signal server_disconnected()
signal connection_closed()
signal connection_failed()

signal on_ping(_ping)

var ping_interval_timer :Timer
var ping_increment_timer :Timer
var ping :int = 28

func _ready():
	get_tree().connect('network_peer_connected', self, '_network_peer_connected')
	get_tree().connect('network_peer_disconnected', self, '_on_peer_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
func setup_ping():
	if is_instance_valid(ping_interval_timer):
		ping_interval_timer.stop()
		ping_interval_timer.queue_free()
		
	if is_instance_valid(ping_increment_timer):
		ping_increment_timer.stop()
		ping_increment_timer.queue_free()
	
	ping_interval_timer = Timer.new()
	ping_interval_timer.wait_time = ping_interval
	ping_interval_timer.autostart = true
	ping_interval_timer.one_shot = false
	ping_interval_timer.connect("timeout", self ,"_on_ping_interval_timer_timeout")
	add_child(ping_interval_timer)
	
	ping_increment_timer = Timer.new()
	ping_increment_timer.wait_time = ping_increment
	ping_increment_timer.autostart = true
	ping_increment_timer.one_shot = false
	ping_increment_timer.connect("timeout", self ,"_on_ping_increment_timer_timeout")
	add_child(ping_increment_timer)
	
func _on_ping_interval_timer_timeout():
	if not is_instance_valid(get_tree().get_network_peer()):
		return
	
	emit_signal("on_ping", ping)
	rpc_unreliable_id(PLAYER_HOST_ID, "_ping", get_tree().get_network_unique_id())
	
func _on_ping_increment_timer_timeout():
	if ping > 998:
		return
		
	ping += 1
	
remote func _ping(from : int):
	if not is_instance_valid(get_tree().get_network_peer()):
		return
	
	rpc_unreliable_id(from, "_pong")
	
remote func _pong():
	ping = 28
	
# for player to want become host
# hosting server
func create_server(_max_player : int = MAX_PLAYERS, _port :int = DEFAULT_PORT) -> int:
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(_port, _max_player)
	if err != OK:
		return err
		
	get_tree().set_network_peer(null) 
	get_tree().set_network_peer(peer)
	emit_signal("server_player_connected", PLAYER_HOST_ID)
	return OK
	
# for player to want become client
# join to server
func connect_to_server(_ip:String = DEFAULT_IP, _port :int = DEFAULT_PORT) -> int:
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(_ip,_port)
	if err != OK:
		return err
		
	for _signal in get_tree().get_signal_connection_list("connected_to_server"):
		get_tree().disconnect("connected_to_server",self, _signal.method)
		
	for _signal in get_tree().get_signal_connection_list("connection_failed"):
		get_tree().disconnect("connection_failed",self, _signal.method)
		
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('connection_failed', self,'_connection_to_server_failed')
	get_tree().set_network_peer(null) 
	get_tree().set_network_peer(peer)
	
	return OK
	
# server just went dive crash LOL
# this function is call for
# pov from joined player
func _on_server_disconnected():
	for _signal in get_tree().get_signal_connection_list("connected_to_server"):
		get_tree().disconnect("connected_to_server",self, _signal.method)
		
	for _signal in get_tree().get_signal_connection_list("connection_failed"):
		get_tree().disconnect("connection_failed",self, _signal.method)
		
	if is_instance_valid(ping_interval_timer):
		ping_interval_timer.stop()
		ping_interval_timer.queue_free()
		
	if is_instance_valid(ping_increment_timer):
		ping_increment_timer.stop()
		ping_increment_timer.queue_free()
		
	emit_signal("server_disconnected")
	
# if player want to disconnect
# from server, just call this func
func disconnect_from_server() -> void:
	if is_instance_valid(ping_interval_timer):
		ping_interval_timer.stop()
		ping_interval_timer.queue_free()
		
	if is_instance_valid(ping_increment_timer):
		ping_increment_timer.stop()
		ping_increment_timer.queue_free()
		
	if not is_instance_valid(get_tree().get_network_peer()):
		return
	
	for _signal in get_tree().get_signal_connection_list("connected_to_server"):
		get_tree().disconnect("connected_to_server",self, _signal.method)
		
	get_tree().get_network_peer().close_connection()
	get_tree().set_network_peer(null)

	emit_signal("connection_closed")
	
# player connect to server
# pov from joined player
func _connected_to_server():
	var local_player_id = get_tree().get_network_unique_id()
	setup_ping()
	
	emit_signal("client_player_connected", local_player_id)
	
# player failed connect to server
# pov from joined player
func _connection_to_server_failed():
	emit_signal("connection_failed")
	
# this will be emit for everybody
# after new player join
func _network_peer_connected(player_network_unique_id : int):
	if get_tree().is_network_server():
		return
		
	emit_signal("player_connected", player_network_unique_id)
	
# this will be emit by everybody
# except diconnected player
func _on_peer_disconnected(player_network_unique_id : int):
	emit_signal("player_disconnected",player_network_unique_id)
	
