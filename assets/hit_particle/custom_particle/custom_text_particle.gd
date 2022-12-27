extends CPUParticles
class_name CustomTextParticle

onready var timer = $Timer

func is_emitting() -> bool:
	return not timer.is_stopped()
	
func display_hit(s :String):
	if is_emitting():
		return
		
	if not mesh is TextMesh:
		return
		
	(mesh as TextMesh).text = s
	
	timer.start()
	
	amount = int(rand_range(2, 4))
	emitting = true
