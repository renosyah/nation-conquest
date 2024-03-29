extends BaseBuilding
class_name Stable

onready var _collision_shape = $CollisionShape

onready var _hp_bar = $hpBar
onready var _mesh_instance = $MeshInstance
onready var _mesh_instance_2 = $MeshInstance2
onready var _barrack_2 = $MeshInstance2/barrack2
onready var _barrack = $MeshInstance/barrack

onready var _highlight_material :SpatialMaterial = $MeshInstance2/barrack2.get_surface_material(0).duplicate()

onready var _area_build = $area_build
onready var _tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	_hp_bar.visible = false
	_mesh_instance.visible = false
	_mesh_instance_2.visible = true
	
	var _team_color_material :SpatialMaterial = _barrack.get_surface_material(3).duplicate()
	_team_color_material.albedo_color = color
	_barrack.set_surface_material(3, _team_color_material)
	
	_area_build.input_ray_pickable = is_selectable
	set_all_highlight_material(_barrack_2, _highlight_material)
	
	set_process(true)
	
func set_all_highlight_material(_mesh :MeshInstance, _material :SpatialMaterial):
	for i in range(_mesh.get_surface_material_count()):
		_mesh.set_surface_material(i, _material)
		
remotesync func _start_building():
	._start_building()
	
	_mesh_instance.visible = true
	_mesh_instance.translation.y -= 10
	_collision_shape.set_deferred("disabled", false)
	
	_tween.interpolate_property(
		_mesh_instance, "translation:y", _mesh_instance.translation.y,
		 _mesh_instance.translation.y + 10, building_time
	)
	_tween.start()
	
remotesync func _finish_building():
	._finish_building()
	
	_mesh_instance_2.visible = false
	_hp_bar.update_bar(hp, max_hp)
	_hp_bar.visible = true
	
func moving(_delta :float) -> void:
	if status == status_deploying:
		can_build = _area_build.get_overlapping_bodies().empty() and translation.distance_to(base_position) < max_distance_from_base
		_highlight_material.albedo_color = Color(1,1,1,0.5) if can_build else Color(1,0,0,0.5)
	
remotesync func _take_damage(damage :int, hp_remain :int) -> void:
	._take_damage(damage, hp_remain)
	_hp_bar.update_bar(hp, max_hp)
	
func _on_area_build_input_event(camera, event, position, normal, shape_idx):
	._on_input_event(camera, event, position, normal, shape_idx)
	
