extends BaseResources

var trees = [
	preload("res://entity/resources/trees/Tree1.obj"),
	preload("res://entity/resources/trees/Tree2.obj"),
	preload("res://entity/resources/trees/Tree3.obj"),
	preload("res://entity/resources/trees/Tree4.obj")
]

onready var _mesh_instance = $MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	_mesh_instance.mesh = trees[rng.randi_range(0, trees.size() - 1)]
	_mesh_instance.rotation_degrees.y = rng.randf_range(0, 180)
	_mesh_instance.software_skinning_transform_normals = false
	_mesh_instance.generate_lightmap = false
	._create_collision_shape(_mesh_instance)
