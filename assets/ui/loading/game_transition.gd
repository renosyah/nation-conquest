extends CanvasLayer

const random_tips = [
	"Focus build farm in early game",
	"Capture flag to gain resource",
	"Build blacksmith to unlock tech",
	"You can repair damage building",
	"Shock troop efective agains range",
	"Archer tower is hard to destroy",
	"Build healing camp to replenish your squad",
	"Trebuchet are powerfull siege engine",
	"Archer tower can unlock radar"
	
]

var pos = 0
onready var _display_random_quote :bool = false
onready var _random_tips = random_tips.duplicate()

onready var _animation_player = $AnimationPlayer
onready var _random_quote_timer = $random_quote_timer
onready var _quote = $Control/VBoxContainer/quote

func change_scene(scene :String):
	_random_tips = random_tips.duplicate()
	_random_tips.shuffle()
	
	_display_random_quote = true
	_on_random_quote_timer_timeout()
	
	_animation_player.play("show")
	
	yield(_animation_player,"animation_finished")
	yield(get_tree().create_timer(5), "timeout")
	
	get_tree().change_scene(scene)
	
func hide_transition():
	_display_random_quote = false
	_animation_player.play_backwards("show")
	
func _on_random_quote_timer_timeout():
	if pos > _random_tips.size() - 1:
		pos = 0
		
	if _display_random_quote:
		_random_quote_timer.start()
		
	_quote.text = _random_tips[pos]
	pos += 1
	
