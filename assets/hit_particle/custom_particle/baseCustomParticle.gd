extends CPUParticles
class_name BaseCustomParticle

var _emmit_timer :Timer
var _is_emiting :bool = false

func _ready():
	set_as_toplevel(true)
	_emmit_timer = Timer.new()
	_emmit_timer.one_shot = true
	_emmit_timer.wait_time = 1.6
	_emmit_timer.connect("timeout", self, "_is_emiting_timeout")
	add_child(_emmit_timer)
	
func is_emitting() -> bool:
	return _is_emiting
	
func display():
	if is_emitting():
		return
		
	on_pre_emmit()
	
	_is_emiting = true
	_emmit_timer.start()
	emitting = true
	
func _is_emiting_timeout():
	_is_emiting = false
	
func on_pre_emmit():
	pass
