extends StaticBody
class_name BaseMap

const land_shader = preload("res://map/shadermaterial.tres")

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
var base_spawn_positions : Array = []

var _input_detection :Node
var _click_position :Vector3

var thread = Thread.new()
onready var _land_shader :ShaderMaterial = land_shader

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
	
func _exit_tree():
	thread.wait_to_finish()
	
func generate_map():
	if not thread.is_active():
		thread.start(self, "_generate_map")

func _generate_map():
	var noise = NoiseMaker.new()
	noise.make_noise(map_seed, 3)
	
	var lands = _create_land(noise)
	land_mesh = lands[0]
	add_child(land_mesh)
	
	land_mesh.create_trimesh_collision()
	
	land_mesh.cast_shadow = false
	land_mesh.generate_lightmap = false
	land_mesh.software_skinning_transform_normals = false

	collision = land_mesh.get_child(0).get_child(0)
	land_mesh.get_child(0).remove_child(collision)
	add_child(collision)
	land_mesh.get_child(0).queue_free()
	
	base_spawn_positions = _generate_base_spawn_points(lands[1])
	spawn_positions = _trim_array(lands[1], 22)
	
	var delay = Timer.new()
	delay.wait_time = 1
	add_child(delay)
	delay.start()
	
	yield(delay, "timeout")
	delay.queue_free()
	
	emit_signal("on_generate_map_completed")
	
func _trim_array(arr :Array, step :int) -> Array:
	randomize()
	arr.shuffle()
	return arr.slice(0, arr.size() - 1, step)
	
func _generate_base_spawn_points(positions_copy :Array) -> Array:
	var edges = [
		# NW
		Vector3(-100, 0, -100),
		
		# SW
		Vector3(100, 0, -100),
		
		# NE
		Vector3(-100, 0, 100),
		
		# SE
		Vector3(100, 0, 100),
	]
	var _spawn_points :Array = [
		# NW
		Vector3.ZERO,
		
		# SW
		Vector3.ZERO,
		
		# NE
		Vector3.ZERO,
		
		# SE
		Vector3.ZERO,
		
		# CENTER
		Vector3.ZERO,
	]
	
	var index :int = 0
	for edge in edges:
		for pos in positions_copy:
			var close_1 = _spawn_points[index].distance_squared_to(edge)
			var close_2 = pos.distance_squared_to(edge)
			if close_2 < close_1 and pos.y > 4:
				_spawn_points[index] = pos
				
		positions_copy.erase(_spawn_points[index])
		index += 1
		
	for pos in positions_copy:
		if _spawn_points[4].y < pos.y:
			_spawn_points[4] = pos
			
	positions_copy.erase(_spawn_points[4])
	
	return _spawn_points
	
	
func _create_land(noise :NoiseMaker) -> Array:
	var inland_positions :Array = []
	
	var _land_mesh = PlaneMesh.new()
	_land_mesh.size = Vector2(map_size, map_size)
	_land_mesh.subdivide_width = map_size * 0.5
	_land_mesh.subdivide_depth = map_size * 0.5

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(_land_mesh, 0)
	
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
		vertext.y = value * map_height
		
		# inland height
		# above sea level
		if vertext.y > 1.5:
			inland_positions.append(vertext)
			
		data_tool.set_vertex(i, vertext)
		
	data.unlock()
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var _land_mesh_instance = MeshInstance.new()
	_land_mesh_instance.mesh = surface_tool.commit()
	_land_mesh_instance.set_surface_material(0, _land_shader)
	
	return [_land_mesh_instance, inland_positions]
	

func _input_event(camera, event, position, normal, shape_idx):
	_click_position = position
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_map_click",_click_position)
	
