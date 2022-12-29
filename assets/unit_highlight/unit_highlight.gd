extends MeshInstance
class_name UnitHighlight

export var color :Color = Color.white

# Called when the node enters the scene tree for the first time.
func _ready():
	var material :SpatialMaterial = get_surface_material(0).duplicate()
	material.albedo_color = color
	mesh.surface_set_material(0, material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
