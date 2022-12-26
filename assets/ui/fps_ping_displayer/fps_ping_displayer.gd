extends HBoxContainer

onready var fps = $fps
onready var ping = $ping

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.connect("on_ping", self, "on_ping")
	
func on_ping(_ping :int):
	ping.text = "Ping : " + str(_ping) + "/ms"
	
func _process(delta):
	fps.text = "Fps : " +  str(Engine.get_frames_per_second())
	
