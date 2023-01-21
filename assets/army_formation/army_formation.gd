extends Spatial
class_name ArmyFormation

export var start_point :Vector3
export var destination_point :Vector3
export var squad_count :int

func get_formation() -> Array:
	_reset_all()
	_create_formation()
	_facing_to_destination()
	
	var positions :Array = []
	for child in get_children():
		positions.append(child.global_transform.origin)
		
	return positions
	
func _create_formation():
	var formation :Array = Utils.get_formation_box(
		translation, squad_count, 5
	)
	
	for i in range(squad_count):
		var pos :Position3D = Position3D.new()
		pos.translation = to_local(formation[i])
		add_child(pos)
		

func _reset_all():
	translation = start_point
	rotation = Vector3.ZERO
	
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
func _facing_to_destination():
	var norm_destination_y :Vector3 = Vector3(
		destination_point.x, translation.y, destination_point.z
	)
	var direction :Vector3 = translation.direction_to(
		norm_destination_y
	)
	var distance :float = translation.distance_to(
		norm_destination_y
	)
	if distance > 1:
		look_at(direction * 100, Vector3.UP)
		
	translation = destination_point
