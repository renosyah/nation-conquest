extends Spatial
class_name HitParticle

export var custom_particle_scene :Resource
export var max_pool :int = 6
var particles :Array = []

func _ready():
	for _i in range(max_pool):
		particles.append(_create_particle())
	
func _create_particle() -> BaseCustomParticle:
	var custom_particle = custom_particle_scene.instance()
	add_child(custom_particle)
	return custom_particle
	
func display_hit(s :String, color :Color, at :Vector3):
	for i in particles:
		if not i.is_emitting():
			if i is CustomTextParticle:
				i.text = s
				i.translation = at
				i.display()
				
			elif i is CustomMeshParticle:
				i.color = color
				i.translation = at
				i.display()
				
			return
