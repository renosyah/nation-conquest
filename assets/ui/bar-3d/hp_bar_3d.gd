extends Sprite3D
class_name HpBar3D

onready var _player_name = $Viewport/VBoxContainer/name
onready var _viewport_hp_bar = $Viewport
onready var _2d_hp_bar = $Viewport/VBoxContainer/hp_bar
onready var _2d_ammo_bar = $Viewport/VBoxContainer/ammo_bar
onready var visibility_notifier = $VisibilityNotifier
onready var visible_timer = $visible_timer

var _is_visible :bool = false

func _ready():
	texture = _viewport_hp_bar.get_texture()
	_2d_ammo_bar.set_hp_bar_color(Color.orange)
	_2d_ammo_bar.show_label(false)
	_is_visible = false
	visible = false
	
func _process(delta):
	if _is_visible:
		visible = visibility_notifier.is_on_screen()
	
func show_label(_show = true):
	_2d_hp_bar.show_label(_show)
	
func update_bar(hp, max_hp : int):
	_2d_hp_bar.update_bar(hp, max_hp)
	
	if _is_visible:
		return
		
	_is_visible = true
	visible_timer.start()
	
func update_ammo_bar(ammo, max_ammo : int):
	_2d_ammo_bar.update_bar(ammo, max_ammo)
	
func set_hp_bar_color(_color : Color):
	_2d_hp_bar.set_hp_bar_color(_color)
	
func set_player_name(_name):
	_player_name.text = _name
	
func _on_visible_timer_timeout():
	_is_visible = false
	visible = false


