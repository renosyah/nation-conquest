extends StaticBody
class_name BaseResources

enum type_resource_enum { none,wood,food,stone }

onready var rng :RandomNumberGenerator = RandomNumberGenerator.new()
export(type_resource_enum) var type_resource = type_resource_enum.none
export var amount :int = 1

var collision :CollisionShape

# performace
var _visibility_notifier :VisibilityNotifier

func _ready() -> void:
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 80
	_visibility_notifier.connect("camera_entered", self, "_on_camera_entered")
	_visibility_notifier.connect("camera_exited", self , "_on_camera_exited")
	add_child(_visibility_notifier)
	
func _create_collision_shape(_mesh :MeshInstance):
	_mesh.create_convex_collision()
	_mesh.software_skinning_transform_normals = false

	collision = _mesh.get_child(0).get_child(0)
	_mesh.get_child(0).remove_child(collision)
	add_child(collision)
	_mesh.get_child(0).queue_free()
	
	collision.rotation_degrees.y = _mesh.rotation_degrees.y
