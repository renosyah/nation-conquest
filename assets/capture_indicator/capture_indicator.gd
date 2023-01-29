extends Spatial
class_name CaptureIndicator

onready var banner = $banner
onready var viewport = $banner/Viewport
onready var capture_indicator_2d = $banner/Viewport/capture_indicator_2d

# Called when the node enters the scene tree for the first time.
func _ready():
	banner.texture = viewport.get_texture()
	
func set_color(_color :Color):
	capture_indicator_2d.set_color(_color)
	
func update_bar(value, max_value : int):
	capture_indicator_2d.update_bar(value, max_value)
