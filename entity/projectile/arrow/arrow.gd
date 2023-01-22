extends BaseProjectile

var enable_fire :bool = false
 
onready var fire = $CPUParticles

func fire():
	.fire()
	
	if enable_fire:
		fire.emitting = true
	
func _arrow_stick_timeout():
	._arrow_stick_timeout()
	
	if enable_fire:
		fire.emitting = false
