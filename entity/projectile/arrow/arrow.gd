extends BaseProjectile

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(target, Vector3.UP)
 
