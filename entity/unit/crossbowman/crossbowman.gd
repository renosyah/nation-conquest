extends "res://entity/unit/archer/archer.gd"

func _create_arrow() -> BaseProjectile:
	#_create_arrow()
	var arrow = arrow_projectile.instance()
	arrow.speed = 14
	arrow.connect("hit", self ,"_arrow_hit", [arrow])
	
	var last_index = get_tree().get_root().get_child_count() - 1
	get_tree().get_root().get_child(last_index).add_child(arrow)
	return arrow
	
