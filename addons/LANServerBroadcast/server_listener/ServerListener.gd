extends Node
class_name ServerListener, 'res://addons/LANServerBroadcast/server_listener/server_listener.png'

signal new_server
signal remove_server
signal error_listening(_msg)

var cleanUpTimer := Timer.new()
var socketUDP := PacketPeerUDP.new()
var listenPort := ServerAdvertiser.DEFAULT_PORT
var knownServers = {}
var is_listening = false

# Number of seconds to wait when a server hasn't been heard from
# before calling remove_server
export (int) var server_cleanup_threshold: int = 3

func _init():
	cleanUpTimer.wait_time = server_cleanup_threshold
	cleanUpTimer.one_shot = false
	cleanUpTimer.autostart = true
	cleanUpTimer.connect("timeout", self, 'clean_up')
	add_child(cleanUpTimer)

func _ready():
	set_process(false)
	
func setup():
	knownServers.clear()
		
	if socketUDP.is_listening():
		return
		
	var listen = socketUDP.listen(listenPort)
	if  listen != OK:
		emit_signal("error_listening", "GameServer LAN service: Error listening on port: " + str(listenPort))
		return
		
	set_process(true)
	
func stop():
	set_process(false)
	emit_signal("remove_server", knownServers.keys())
	knownServers.clear()
	socketUDP.close()
	
	
func _process(delta):
	if socketUDP.get_available_packet_count() > 0:
		var serverIp = socketUDP.get_packet_ip()
		var serverPort = socketUDP.get_packet_port()
		var array_bytes = socketUDP.get_packet()
		
		if serverIp != '' and serverPort > 0:
			# We've discovered a new server! Add it to the list and let people know
			if not knownServers.has(serverIp):
				var serverMessage = array_bytes.get_string_from_ascii()
				var gameInfo = parse_json(serverMessage)
				gameInfo.ip = serverIp
				gameInfo.lastSeen = OS.get_unix_time()
				knownServers[serverIp] = gameInfo
				#print("New server found: %s - %s:%s" % [gameInfo.name, gameInfo.ip, gameInfo.port])
				emit_signal("new_server", gameInfo)
			
func clean_up():
	var now = OS.get_unix_time()
	var erased_servers = []
	for serverIp in knownServers:
		var serverInfo = knownServers[serverIp]
		if (now - serverInfo.lastSeen) > server_cleanup_threshold:
			erased_servers.append(serverIp)
			emit_signal("remove_server", [serverIp])
			
	for i in erased_servers:
		knownServers.erase(i)
	
func force_clean_up():
	var erased_servers = []
	for serverIp in knownServers:
		erased_servers.append(serverIp)
			
	for i in erased_servers:
		knownServers.erase(i)
	
func _exit_tree():
	if socketUDP.is_listening():
		socketUDP.close()
