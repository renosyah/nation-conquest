extends BaseBuilding
class_name CapturePoint

signal capture_score(_capture_point, _amount)
signal point_captured(_capture_point, _by_team)

export var amount :int = 25

export var capture_point :int = 100
export var max_capture_point :int = 100
export var capture_rate :int = 10

export var team_capturing :int = 0

export var is_server :bool = false

onready var capture_area = $capture_area
onready var flag_pole = $MeshInstance/flag_pole
onready var flag_pole_material :SpatialMaterial = flag_pole.get_surface_material(1).duplicate()
onready var capture_indicator = $capture_indicator
onready var ray_cast = $RayCast

# Called when the node enters the scene tree for the first time.
func _ready():
	status = status_deployed
	flag_pole.set_surface_material(1, flag_pole_material)
	set_process(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func moving(delta :float) -> void:
	.moving(delta)
	
	# move_and_slide(Vector3.DOWN * 25, Vector3.UP)
	translation += Vector3.DOWN * 15 * delta
	
	# if is_on_floor():
	if ray_cast.is_colliding():
		ray_cast.set_deferred("enabled", false)
		set_process(false)
		return
		
func puppet_moving(delta :float) -> void:
	#.puppet_moving(delta)
	pass
	
func take_damage(damage :int) -> void:
	#.take_damage(damage)
	pass
	
remotesync func _update_capturing_status(_capture_point :int, _team_capturing :int, _team_capturing_color :Color):
	capture_point = _capture_point
	team_capturing = _team_capturing
	
	capture_indicator.set_color(_team_capturing_color)
	capture_indicator.update_bar(capture_point, max_capture_point)
	
remotesync func _on_capture_point_captured(_team_capturing :int, _team_capturing_color :Color):
	team = _team_capturing
	color = _team_capturing_color
	flag_pole_material.albedo_color = color
	emit_signal("point_captured", self, _team_capturing)
	
func _on_capturing_timer_timeout():
	if not is_server:
		return
		
	var teams :Dictionary = {}
	
	for object in capture_area.get_overlapping_bodies():
		if object is BaseUnit:
			teams[object.team] = object.color
			
		if teams.size() > 2:
			break
			
	if teams.empty() or teams.keys().size() > 1:
		return
		
	if team == teams.keys()[0] and capture_point == max_capture_point:
		return
		
	if team == teams.keys()[0] and capture_point < max_capture_point:
		capture_point = clamp(capture_point + capture_rate, 0, max_capture_point)
		rpc("_update_capturing_status", capture_point, team, color)
		return
		
	var capture_color_indicator = color
		
	if team_capturing == teams.keys()[0]:
		capture_point = clamp(capture_point + capture_rate, 0, max_capture_point)
		capture_color_indicator = teams.values()[0]
		
		if capture_point == max_capture_point:
			team = team_capturing
			color = teams.values()[0]
			rpc("_on_capture_point_captured", team, color)
			
			team_capturing = 0
	else:
		capture_point = clamp(capture_point - capture_rate, 0, max_capture_point)
		capture_color_indicator = color
		
		if capture_point == 0:
			capture_color_indicator = teams.values()[0]
			team_capturing = teams.keys()[0]
			
	rpc("_update_capturing_status", capture_point, team_capturing, capture_color_indicator)
	
func _on_capture_score_timer_timeout():
	emit_signal("capture_score", self, amount)

















