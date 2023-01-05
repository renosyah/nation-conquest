extends MarginContainer

var _moving_direction :Vector2 = Vector2.ZERO
var _zoom :float = 25.0
var _touch_index : int = -1

var events : Dictionary = {}

var min_zoom : float = 10.0
var max_zoom : float = 30.0
var zoom_sensitivity : float = 10.0
var zoom_speed : float = 0.05

var last_drag_distance : float = 0.0
var drag_speed : float = 0.055

func get_moving_direction() -> Vector2:
	return _moving_direction * _zoom * drag_speed
	
func get_zoom() -> float:
	return _zoom
	
func _process(delta):
	if Engine.get_frames_per_second() > 25:
		_moving_direction = _moving_direction.linear_interpolate(
			Vector2.ZERO, 25 * delta
		)
	else:
		_moving_direction = Vector2.ZERO
	
func _draging(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed and _is_point_inside_area(event.position):
				if _touch_index == -1:
					_touch_index = event.index
				#get_tree().set_input_as_handled()
				
		elif event.index == _touch_index:
			_touch_index = -1
			_moving_direction = Vector2.ZERO
			#get_tree().set_input_as_handled()
			
	if event is InputEventScreenDrag:
		if events.size() == 1:
			_moving_direction = event.relative
			#get_tree().set_input_as_handled()
			
		else:
			_moving_direction = Vector2.ZERO
			
			
func _zooming(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and _is_point_inside_area(event.position):
			if event.button_index == BUTTON_WHEEL_UP:
				var new_zoom = (1 - zoom_speed) 
				_zoom = clamp(_zoom * new_zoom, min_zoom, max_zoom)
				
			if event.button_index == BUTTON_WHEEL_DOWN:
				var new_zoom = (1 + zoom_speed) 
				_zoom = clamp(_zoom * new_zoom, min_zoom, max_zoom)
				
	if event is InputEventScreenTouch:
		if event.pressed and _is_point_inside_area(event.position):
			events[event.index] = event
		else:
			events.erase(event.index)
			
	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 2:
			if not events.has(0)or not events.has(1):
				return
				
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				_zoom = clamp(_zoom * new_zoom, min_zoom, max_zoom)
				last_drag_distance = drag_distance
				#get_tree().set_input_as_handled()
				
func _unhandled_input(event: InputEvent):
	_draging(event)
	_zooming(event)
	
func _is_point_inside_area(point: Vector2) -> bool:
	var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y
