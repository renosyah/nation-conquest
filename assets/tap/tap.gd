extends Spatial
class_name Tap

export var color :Color = Color.white setget _set_color

onready var animation_player = $AnimationPlayer
onready var mesh_instance = $MeshInstance
onready var timer = $Timer

var material :SpatialMaterial
var is_visible :bool = false

func _ready():
	material = mesh_instance.get_surface_material(0).duplicate()
	material.albedo_color = color
	mesh_instance.set_surface_material(0, material)
	set_as_toplevel(true)

func _set_color(val :Color):
	color = val
	material.albedo_color = color
	
func tap():
	is_visible = true
	timer.start()
	animation_player.play("tap")

func is_visible():
	return is_visible

func _on_Timer_timeout():
	is_visible = false
