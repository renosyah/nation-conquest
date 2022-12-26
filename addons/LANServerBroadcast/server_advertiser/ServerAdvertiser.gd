extends Node
class_name ServerAdvertiser, 'res://addons/LANServerBroadcast/server_advertiser/server_advertiser.png'

const DEFAULT_PORT := 3111

# How often to broadcast out to the network that this host is active
export (float) var broadcast_interval: float = 1.0
var serverInfo := {"name": "LAN Game"}

var socketUDP: PacketPeerUDP
var broadcastTimer := Timer.new()
var broadcastPort := DEFAULT_PORT

func _ready():
	broadcastTimer.wait_time = broadcast_interval
	broadcastTimer.one_shot = true
	broadcastTimer.autostart = false
	broadcastTimer.connect("timeout", self, "broadcast") 
	add_child(broadcastTimer)
	
func setup():
	dismantle()
	
	if get_tree().is_network_server():
		broadcastTimer.start()
		
		socketUDP = PacketPeerUDP.new()
		socketUDP.set_broadcast_enabled(true)
		socketUDP.set_dest_address('255.255.255.255', broadcastPort)
	
func broadcast():
	#print('Broadcasting game...')
	var packetMessage := to_json(serverInfo)
	var packet := packetMessage.to_ascii()
	socketUDP.put_packet(packet)
	broadcastTimer.start()
	
func dismantle():
	broadcastTimer.stop()
	
	if socketUDP != null:
		socketUDP.close()
	
func _exit_tree():
	dismantle()
