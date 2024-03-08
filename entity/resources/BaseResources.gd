extends Spatial
class_name BaseResources

onready var rng :RandomNumberGenerator = RandomNumberGenerator.new()

# performace
var _visibility_notifier :VisibilityNotifier

func _ready() -> void:
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 80
	_visibility_notifier.connect("camera_entered", self, "_on_camera_entered")
	_visibility_notifier.connect("camera_exited", self , "_on_camera_exited")
	add_child(_visibility_notifier)
	
func _on_camera_entered(_camera: Camera):
	visible = true
	
func _on_camera_exited(_camera: Camera):
	visible = false
	

























