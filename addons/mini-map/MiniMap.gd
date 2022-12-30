extends MarginContainer
class_name MiniMap

signal on_minimap_click(_minimap, _pos_v2, _pos_v3)

const DIMESION_MULTIPLIER = 10.0

export var camera_offset :Vector2 = Vector2.ZERO
export var border_color :Color = Color.white
export var interval_update :bool = false

onready var _zoom :float = 1.0

onready var _grid = $MarginContainer/Grid
onready var _frame = $Frame
onready var _camera_marker = $MarginContainer/Grid/Camera
onready var _entity_marker_template = $MarginContainer/Grid/EntityMarker
onready var _get_viewport_rect_size :Vector2 = get_viewport_rect().size
onready var _timer = $Timer
onready var _input_detection = $input_detection

var _camera :Camera
var _map_objects :Array = []
var _markers :Dictionary = {}

func _ready():
	_frame.self_modulate = border_color
	set_process(false)
	
	if interval_update:
		_timer.start()
	else:
		set_process(true)
	
func _process(_delta):
	_update_minimap()
	
func _update_minimap():
	if not is_instance_valid(_camera):
		_camera = get_viewport().get_camera()
		return
		
	var _grid_scale :Vector2 = _grid.rect_size / (
		_get_viewport_rect_size * _zoom
	)
	var cam_vec2_pos :Vector2 = Vector2(
		_camera.global_transform.origin.x,_camera.global_transform.origin.z
	)
	cam_vec2_pos += camera_offset
	
	for object_path in _markers.keys():
		var item = get_node_or_null(object_path)
		
		if is_instance_valid(item):
			var item_vec2_pos :Vector2 = Vector2(item.global_transform.origin.x, item.global_transform.origin.z)
			var env_vector :Vector2 = (item_vec2_pos * DIMESION_MULTIPLIER - cam_vec2_pos * DIMESION_MULTIPLIER)
			var obj_pos :Vector2 = env_vector * _grid_scale + _grid.rect_size / 2
			var in_minimap :bool = _is_position_in_rect(obj_pos)
			
			_markers[object_path].scale = Vector2(1, 1) if in_minimap else Vector2(0.8, 0.8)
			_markers[object_path].modulate.a = 1.0 if in_minimap else 0.8
			
			obj_pos.x = clamp(obj_pos.x, 0, _grid.rect_size.x)
			obj_pos.y = clamp(obj_pos.y, 0, _grid.rect_size.y)
			_markers[object_path].position = obj_pos
			
		else:
			remove_object(object_path)
			return
			
func _is_position_in_rect(obj_pos :Vector2) -> bool:
	return _grid.get_rect().has_point(obj_pos + _grid.rect_position)
	
func add_object(object_path :NodePath, color :Color = Color.white):
	var object = get_node_or_null(object_path)
	if not is_instance_valid(object):
		return
		
	var new_marker = _entity_marker_template.duplicate()
	new_marker.self_modulate = color
	new_marker.show()
	_grid.add_child(new_marker)
	
	_markers[object_path] = new_marker
	
func remove_object(object :NodePath):
	if not _markers.has(object):
		return
		
	_grid.remove_child(_markers[object])
	_markers[object].queue_free()
	_markers.erase(object)
	
func set_zoom(value :float):
	_zoom = clamp(_zoom , 1, 5)

func _on_Timer_timeout():
	_timer.start()
	_update_minimap()

func _on_MiniMap_gui_input(event):
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		
		# still experiment
		var _grid_scale :Vector2 = _grid.rect_size / (
			_get_viewport_rect_size * _zoom
		) 
		var cam_vec2_pos :Vector2 = Vector2(
			_camera.global_transform.origin.x,_camera.global_transform.origin.z
		)
		cam_vec2_pos += camera_offset
		
		var obj_pos :Vector2 = event.position / _grid_scale - _grid.rect_size * 2
		var env_vector :Vector2 = obj_pos / DIMESION_MULTIPLIER + cam_vec2_pos / DIMESION_MULTIPLIER
		var v3 :Vector3 = Vector3(env_vector.x, 0.0, env_vector.y)
		
		if _is_position_in_rect(event.position):
			emit_signal("on_minimap_click", self, event.position, v3)
		
	

