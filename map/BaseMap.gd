extends StaticBody
class_name BaseMap

const land_shader = preload("res://map/shadermaterial.tres")
const water_shader = preload("res://map/water_shadermaterial.tres")

signal on_generate_map_completed
signal on_map_click(_pos)

export var map_seed :int = 1
export var map_size :float = 200
export var map_scale :float = 1
export var map_land_color :Color = Color(0, 0.282353, 0.039216)
export var map_sand_color :Color = Color(0.521569, 0.380392, 0)
export var map_water_color :Color = Color(0, 0.196078, 0.392157)
export var map_height :int = 10

var land_mesh :MeshInstance
var collision :CollisionShape
var spawn_positions : Array = []

var _input_detection :Node
var _click_position :Vector3

onready var _land_shader :ShaderMaterial = land_shader
onready var _water_shader :ShaderMaterial = water_shader

func _ready():
	map_land_color = Color(
		stepify(map_land_color.r, 0.01),
		stepify(map_land_color.g, 0.01),
		stepify(map_land_color.b, 0.01),
		1.0
	)
	map_sand_color = Color(
		stepify(map_sand_color.r, 0.01),
		stepify(map_sand_color.g, 0.01),
		stepify(map_sand_color.b, 0.01),
		1.0
	)
	
	_land_shader.set_shader_param("grass_color", map_land_color)
	_land_shader.set_shader_param("sand_color", map_sand_color)
	
	_input_detection = preload("res://addons/Godot-Touch-Input-Manager/input_detection.tscn").instance()
	_input_detection.connect("any_gesture", self, "_on_input_detection_any_gesture")
	add_child(_input_detection)
	
	connect("input_event", self, "_input_event")
	
func generate_map():
	var noise = NoiseMaker.new()
	noise.make_noise(map_seed, 3)
	
	var lands = _create_land(noise)
	land_mesh = lands[0]
	add_child(land_mesh)
	
	land_mesh.cast_shadow = false
	land_mesh.generate_lightmap = false
	land_mesh.software_skinning_transform_normals = false

	collision = land_mesh.get_child(0).get_child(0)
	land_mesh.get_child(0).remove_child(collision)
	add_child(collision)
	land_mesh.get_child(0).queue_free()
	
	var water = _create_water()
	add_child(water)
	
	spawn_positions = _create_spawns(lands[1])
	
	emit_signal("on_generate_map_completed")
	
func _create_spawns(inland_positions :Array) -> Array:
	var stuffs = []
	
	var trim_inland_positions = _trim_array(inland_positions, 22)
	for pos in trim_inland_positions:
		if pos.distance_squared_to(translation) < map_size * 20:
			stuffs.append(pos)
		
	return stuffs
	
	
func _trim_array(arr :Array, step :int) -> Array:
	var new_arr = []
	for i in range(0, arr.size(), step):
		new_arr.append(arr[i])
		
	return new_arr
	
	
func _create_land(noise :NoiseMaker) -> Array:
	var inland_positions :Array = []
	
	var land_mesh = PlaneMesh.new()
	land_mesh.size = Vector2(map_size, map_size)
	land_mesh.subdivide_width = map_size * 0.5
	land_mesh.subdivide_depth = map_size * 0.5

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(land_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	var gradient = CustomGradientTexture.new()
	gradient.gradient = Gradient.new()
	gradient.type = CustomGradientTexture.GradientType.RADIAL
	gradient.size = Vector2.ONE * map_size + Vector2.ONE

	var data = gradient.get_data()
	data.lock()
	
	for i in range(data_tool.get_vertex_count()):
		var vertext = data_tool.get_vertex(i)
		var value = noise.get_noise(vertext * map_scale)
		var gradient_value = data.get_pixel(
			(vertext.x + map_size) * 0.5, (vertext.z + map_size) * 0.5
		).r * 2.2
		value -= gradient_value
		value = clamp(value, -0.075, 1)
		vertext.y = value *  (map_height + 2.0)
		if value > 0.15:
			inland_positions.append(vertext)
			
		data_tool.set_vertex(i, vertext)
		
	data.unlock()
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var land_mesh_instance = MeshInstance.new()
	land_mesh_instance.mesh = surface_tool.commit()
	land_mesh_instance.set_surface_material(0, _land_shader)
	land_mesh_instance.create_trimesh_collision()
	
	return [land_mesh_instance, inland_positions]
	
func _create_water() -> MeshInstance:
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(map_size, map_size)
	
	var water_mesh_instance = MeshInstance.new()
	water_mesh_instance.mesh = water_mesh
	water_mesh_instance.set_surface_material(0, _water_shader)
	
	water_mesh_instance.cast_shadow = false
	water_mesh_instance.generate_lightmap = false
	water_mesh_instance.software_skinning_transform_normals = false
	
	return water_mesh_instance
	
func _input_event(camera, event, position, normal, shape_idx):
	_click_position = position
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_map_click",_click_position)
	
