extends BaseBuilding
class_name Trebuchet

onready var _collision_shape = $CollisionShape

onready var _hp_bar = $hpBar
onready var _hit_particle = $hit_particle
onready var _input_detection = $input_detection

onready var _trebuchet_turret = $trebuchet_turret
onready var _mesh_instance_2 = $MeshInstance2
onready var _barrack_2 = $MeshInstance2/barrack2

onready var _highlight_material :SpatialMaterial = $MeshInstance2/barrack2.get_surface_material(0).duplicate()
onready var _spotting_area = $Area/CollisionShape

onready var _area = $Area
onready var _area_build = $area_build
onready var _tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	_hp_bar.visible = false
	_trebuchet_turret.visible = false
	_mesh_instance_2.visible = true
	
	_trebuchet_turret.is_master = _is_master()
	_trebuchet_turret.set_team_color(color)
	_trebuchet_turret.player_id = player_id
	_trebuchet_turret.team = team

	_area_build.input_ray_pickable = is_selectable
	_barrack_2.set_surface_material(0, _highlight_material)
	
	set_process(true)
	
remotesync func _start_building():
	._start_building()
	
	_trebuchet_turret.visible = true
	_trebuchet_turret.translation.y -= 10
	_collision_shape.set_deferred("disabled", false)
	
	_tween.interpolate_property(
		_trebuchet_turret, "translation:y",_trebuchet_turret.translation.y,
		 _trebuchet_turret.translation.y + 10, building_time
	)
	_tween.start()
	
remotesync func _finish_building():
	._finish_building()
	
	var shape :CylinderShape = _spotting_area.shape.duplicate() as CylinderShape
	shape.radius = _trebuchet_turret.attack_range + 2
	_spotting_area.shape = shape
	
	_mesh_instance_2.visible = false
	_hp_bar.update_bar(hp, max_hp)
	_hp_bar.visible = true
	
func moving(delta :float) -> void:
	if status == status_deploying:
		can_build = _area_build.get_overlapping_bodies().empty() and translation.distance_to(base_position) < max_distance_from_base
		_highlight_material.albedo_color = Color(1,1,1,0.5) if can_build else Color(1,0,0,0.5)
	
remotesync func _take_damage(damage :int, hp_remain :int) -> void:
	._take_damage(damage, hp_remain)
	
	_hp_bar.update_bar(hp, max_hp)
	_hit_particle.display_hit(
		"-" + str(damage), Color.white,
		global_transform.origin
	)
	
func _on_area_build_input_event(camera, event, position, normal, shape_idx):
	if status != status_deployed:
		return
		
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("building_selected", self)
		
remotesync func _attack_target(_target_path :NodePath):
	var _target = get_node_or_null(_target_path)
	if not is_instance_valid(_target):
		return
		
	if _trebuchet_turret.is_attacking:
		return
		
	_trebuchet_turret.is_attacking = true
	_trebuchet_turret.attack_to = _target
	
func _spotted_target():
	if _trebuchet_turret.is_attacking:
		return
		
	for body in _area.get_overlapping_bodies():
		if not is_instance_valid(body):
			continue
			
		if body is BaseUnit or body is BaseBuilding:
			if body.team == team:
				continue
				
			rpc("_attack_target", body.get_path())
			return
			
func _on_agro_timer_timeout():
	if not _is_master:
		return
		
	if is_dead:
		return
		
	if status != status_deployed:
		return
		
	_spotted_target()
