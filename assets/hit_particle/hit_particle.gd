extends Spatial
class_name HitParticle

const custom_particle_scene = preload("res://assets/hit_particle/custom_particle/custom_text_particle.tscn")

export var enable_extra :bool = false
export var max_pool :int = 4
var particles :Array = []

func _ready():
	set_as_toplevel(true)
	for i in range(max_pool):
		particles.append(_create_particle())
	
func _create_particle() -> CustomTextParticle:
	var custom_particle = custom_particle_scene.instance()
	add_child(custom_particle)
	return custom_particle
	
func display_hit(s :String):
	for i in particles:
		if not i.is_emitting():
			i.display_hit(s)
			return
			
	if not enable_extra:
		return
		
	var _create_new = _create_particle()
	_create_new.display_hit(s)
	
	particles.append(_create_new)
	_create_new.display_hit(s)
	
	
	
	
	
	
