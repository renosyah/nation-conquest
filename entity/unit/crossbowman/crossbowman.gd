extends "res://entity/unit/archer/archer.gd"

func _create_arrow() -> BaseProjectile:
	#_create_arrow()
	var arrow = arrow_projectile.instance()
	arrow.speed = 14
	arrow.connect("hit", self ,"_arrow_hit")
	add_child(arrow)
	return arrow
	
