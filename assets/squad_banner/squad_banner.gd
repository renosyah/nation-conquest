extends Spatial
class_name SquadBanner

onready var banner = $banner
onready var viewport = $banner/Viewport
onready var banner_2d = $banner/Viewport/banner_2d

# Called when the node enters the scene tree for the first time.
func _ready():
	banner.texture = viewport.get_texture()
	
func set_player_name(_name :String):
	banner_2d.set_player_name(_name)
	
func set_squad_number(_number :int):
	banner_2d.set_squad_number(_number)

func set_banner_color(_banner_color, _outline_color :Color):
	banner_2d.set_banner_color(_banner_color, _outline_color)
	
func show_hurt():
	banner_2d.show_hurt()
