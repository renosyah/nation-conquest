extends Spatial
class_name BuildingFloatingOption

signal demolish
signal repair

var building_name:String
var camera :Spatial

onready var _building_name = $pivot/building_name
onready var _input_detection = $input_detection

var option :int

# Called when the node enters the scene tree for the first time.
func _ready():
	(_building_name.mesh as TextMesh).text = building_name

func _process(delta):
	if not is_instance_valid(camera):
		return
		
	var pos :Vector3 = global_transform.origin
	var cam_pos :Vector3 = camera.global_transform.origin
	var cam_pos_xz :Vector3 = Vector3(cam_pos.x, pos.y, cam_pos.z)
	
	var _transform = transform.looking_at(cam_pos_xz, Vector3.UP)
	transform = transform.interpolate_with(_transform, 5 * delta)

func _on_repair_button_input_event(camera, event, position, normal, shape_idx):
	option = 0
	_input_detection.check_input(event)

func _on_demolish_button_input_event(camera, event, position, normal, shape_idx):
	option = 1
	_input_detection.check_input(event)

func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		if option == 0:
			emit_signal("repair")
			
		elif option == 1:
			emit_signal("demolish")
			
func _on_Timer_timeout():
	queue_free()



























