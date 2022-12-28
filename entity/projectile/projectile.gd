extends Spatial
class_name BaseProjectile

signal hit

export var speed :int = 12
export var target :Vector3
export var margin :int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	look_at(target, Vector3.UP)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance :float = translation.distance_squared_to(target)
	if distance <= margin:
		emit_signal("hit")
		queue_free()
		return
		
	var direction :Vector3 = translation.direction_to(target)
	translation += direction * speed * delta
