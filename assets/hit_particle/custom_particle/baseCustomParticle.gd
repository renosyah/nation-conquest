extends CPUParticles
class_name BaseCustomParticle

var _emmit_timer :Timer

func _ready():
	set_as_toplevel(true)
	_emmit_timer = Timer.new()
	_emmit_timer.one_shot = true
	_emmit_timer.wait_time = 1.6
	add_child(_emmit_timer)
	
func is_emitting() -> bool:
	return not _emmit_timer.is_stopped()
	
func display():
	if is_emitting():
		return
		
	on_pre_emmit()

	_emmit_timer.start()
	emitting = true
	
func on_pre_emmit():
	pass
