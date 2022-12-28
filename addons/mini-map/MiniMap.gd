extends MarginContainer
class_name MiniMap

const DIMESION_MULTIPLIER = 50.0

export var camera_offset :Vector2 = Vector2.ZERO
export var border_color :Color = Color.white
export var interval_update :bool = false

onready var _zoom :float = 2.5

onready var _grid = $MarginContainer/Grid
onready var _frame = $Frame
onready var _camera_marker = $MarginContainer/Grid/Camera
onready var _entity_marker_template = $MarginContainer/Grid/EntityMarker
onready var _get_viewport_rect_size :Vector2 = get_viewport_rect().size
onready var _timer = $Timer

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
			var in_minimap :bool = _grid.get_rect().has_point(obj_pos + _grid.rect_position)
			
			_markers[object_path].scale = Vector2(1, 1) if in_minimap else Vector2(0.8, 0.8)
			_markers[object_path].modulate.a = 1.0 if in_minimap else 0.8
			
			obj_pos.x = clamp(obj_pos.x, 0, _grid.rect_size.x)
			obj_pos.y = clamp(obj_pos.y, 0, _grid.rect_size.y)
			_markers[object_path].position = obj_pos
			_markers[object_path].visible = item.visible
			
		else:
			remove_object(object_path)
			return
			
			
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
		
	_markers[object].queue_free()
	_markers.erase(object)
	
func set_zoom(value :float):
	_zoom = clamp(_zoom , 0.5, 5)

func _on_Timer_timeout():
	_timer.start()
	_update_minimap()
