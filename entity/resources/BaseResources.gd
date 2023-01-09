extends StaticBody
class_name BaseResources

enum type_resource_enum { none,wood,food,stone }

onready var rng :RandomNumberGenerator = RandomNumberGenerator.new()
export(type_resource_enum) var type_resource = type_resource_enum.none
export var amount :int = 1

var collision :CollisionShape

func _create_collision_shape(_mesh :MeshInstance):
	_mesh.create_trimesh_collision()
	
	_mesh.cast_shadow = false
	_mesh.generate_lightmap = false
	_mesh.software_skinning_transform_normals = false

	collision = _mesh.get_child(0).get_child(0)
	_mesh.get_child(0).remove_child(collision)
	add_child(collision)
	_mesh.get_child(0).queue_free()
	
	collision.rotation_degrees.y = _mesh.rotation_degrees.y
