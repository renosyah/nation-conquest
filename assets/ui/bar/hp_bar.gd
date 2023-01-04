extends Control

onready var _hp_bar = $hp_bar
onready var _hp_bar_bg = $hp_bar_bg
onready var _tween = $Tween
onready var _label = $RichTextLabel

func show_label(_show = true):
	_label.visible = _show

func update_bar(hp, max_hp : int):
	_label.text = str(hp) + "/" + str(max_hp)
	_hp_bar_bg.max_value = float(max_hp)
	_tween.interpolate_property(_hp_bar_bg, "value", _hp_bar_bg.value, float(hp), Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	_hp_bar.max_value = float(max_hp)
	if hp > _hp_bar.value:
		_tween.interpolate_property(_hp_bar, "value", _hp_bar.value, float(hp), Tween.TRANS_SINE, Tween.EASE_IN)
		_tween.start()
		return
	
	_hp_bar.value = float(hp)
	
func set_hp_bar_color(_color : Color):
	_hp_bar.tint_progress = _color
