extends BaseResources

var rocks = [
	preload("res://entity/resources/rock/Rock1.obj"), 
	preload("res://entity/resources/rock/Rock2.obj"), 
	preload("res://entity/resources/rock/Rock3.obj")
]

onready var _mesh_instance = $MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	_mesh_instance.mesh = rocks[rng.randi_range(0, rocks.size() - 1)]
	_mesh_instance.rotation_degrees.y = rng.randf_range(0, 180)
	_mesh_instance.software_skinning_transform_normals = false
	_mesh_instance.generate_lightmap = false
	._create_collision_shape(_mesh_instance)
