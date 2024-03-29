extends KinematicBody
class_name BaseEntity

# owner
var player_id :int
var player_name :String

# performace
var _visibility_notifier :VisibilityNotifier

# misc network
var _network_timmer :Timer
var _is_online :bool = false
var _is_master :bool = false

############################################################
# multiplayer func
func _network_timmer_timeout() -> void:
	_is_online = _is_network_running()
	
############################################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 60
	_visibility_notifier.connect("camera_entered", self, "_on_camera_entered")
	_visibility_notifier.connect("camera_exited", self , "_on_camera_exited")
	add_child(_visibility_notifier)
	
	_setup_network_timer()
	
func _on_camera_entered(_camera: Camera):
	visible = true
	
func _on_camera_exited(_camera: Camera):
	visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta :float) -> void:
	moving(delta)
	
	if not _is_online:
		return
	
	if _is_master:
		master_moving(delta)
	else:
		puppet_moving(delta)
	
func moving(_delta :float) -> void:
	pass
	
func master_moving(_delta :float) -> void:
	pass
	
func puppet_moving(_delta :float) -> void:
	pass
	
############################################################
# multiplayer func
func _is_network_running() -> bool:
	var _peer :NetworkedMultiplayerPeer = get_tree().network_peer
	if not is_instance_valid(_peer):
		return false
		
	if _peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		return false
		
	return true
	
func _is_network_master() -> bool:
	if not get_tree().network_peer:
		return false
		
	if not is_network_master():
		return false
		
	return true
	
func _setup_network_timer() -> void:
	_is_online = _is_network_running()
	_is_master = _is_network_master()
	
	if not _is_master:
		return
		
	if is_instance_valid(_network_timmer):
		_network_timmer.stop()
		_network_timmer.queue_free()
		
	_network_timmer = Timer.new()
	_network_timmer.wait_time = Network.LATENCY_DELAY
	_network_timmer.connect("timeout", self , "_network_timmer_timeout")
	_network_timmer.autostart = true
	add_child(_network_timmer)
	
























