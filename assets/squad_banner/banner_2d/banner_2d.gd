extends VBoxContainer

onready var player_name = $player_name
onready var number = $MarginContainer/banner/number
onready var banner = $MarginContainer/banner
onready var outline = $MarginContainer/outline
onready var animation_player = $AnimationPlayer

func set_player_name(_name :String):
	player_name.text = _name
	
func set_squad_number(_number :int):
	number.text = str(_number)

func set_banner_color(_banner_color, _outline_color :Color):
	banner.self_modulate = _banner_color
	banner.self_modulate.a = 0.7
	
	outline.self_modulate = _outline_color
	
func show_hurt():
	animation_player.play("hurt")
