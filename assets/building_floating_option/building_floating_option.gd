extends Spatial
class_name BuildingFloatingOption

signal demolish
signal repair
signal info

var building_name:String
var camera :Spatial
var to_pos :Vector3

onready var _building_name = $pivot/building_name
onready var _input_detection = $input_detection
onready var _tween = $Tween

var option :int

# Called when the node enters the scene tree for the first time.
func _ready():
	(_building_name.mesh as TextMesh).text = building_name
	
	_tween.interpolate_property(self, "translation", translation, to_pos, 0.8, Tween.TRANS_LINEAR)
	_tween.start()
	
func _process(delta):
	if not is_instance_valid(camera):
		return
		
	var pos :Vector3 = global_transform.origin
	var cam_pos :Vector3 = camera.global_transform.origin
	var cam_pos_xz :Vector3 = Vector3(cam_pos.x, pos.y, cam_pos.z)
	
	var _transform = transform.looking_at(cam_pos_xz , Vector3.UP)
	transform = transform.interpolate_with(_transform, 5 * delta)
	
func _on_repair_button_input_event(_camera, event, _position, _normal, _shape_idx):
	option = 0
	_input_detection.check_input(event)

func _on_demolish_button_input_event(_camera, event, _position, _normal, _shape_idx):
	option = 1
	_input_detection.check_input(event)

func _on_info_button_input_event(_camera, event, _position, _normal, _shape_idx):
	option = 2
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		match option:
			0:
				emit_signal("repair")
			1:
				emit_signal("demolish")
			2:
				emit_signal("info")
			
func _on_Timer_timeout():
	queue_free()





























