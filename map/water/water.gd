extends StaticBody
class_name Water

export var size :float = 200

var water_mesh_instance :MeshInstance
var collision :CollisionShape

onready var _water_shader :ShaderMaterial = preload("res://map/water_shadermaterial.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(size, size)
	
	water_mesh_instance = MeshInstance.new()
	water_mesh_instance.mesh = water_mesh
	water_mesh_instance.set_surface_material(0, _water_shader)
	water_mesh_instance.create_trimesh_collision()
	
	water_mesh_instance.cast_shadow = false
	water_mesh_instance.software_skinning_transform_normals = false
	
	add_child(water_mesh_instance)
	
	collision = water_mesh_instance.get_child(0).get_child(0)
	water_mesh_instance.get_child(0).remove_child(collision)
	add_child(collision)
	water_mesh_instance.get_child(0).queue_free()
	
	water_mesh_instance.translation.y += 0.5
