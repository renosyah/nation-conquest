extends Spatial

var player_id :int
export var team :int = 0

export var is_attacking :bool = false
var attack_to = null
export var attack_damage :int = 180
export var attack_delay :float = 10
export var attack_range :float = 36

export var is_master :bool = false

onready var base = $base

onready var animation_player = $AnimationPlayer
onready var firing_delay = $firing_delay
onready var position_3d = $Position3D
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var area_damage = $AreaDamage

onready var material :SpatialMaterial = base.get_surface_material(1).duplicate()

var _projectile_pool :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	base.set_surface_material(1, material)
	audio_stream_player_3d.unit_size = Global.sound_amplified
	
	area_damage.set_as_toplevel(true)
	
	_projectile_pools()
	
	set_process(true)
	
func set_team_color(color :Color):
	material.albedo_color = color
	
func _projectile_pools():
	for i in range(4):
		_projectile_pool.append(_create_projectile())
	
func _get_projectile() -> BaseProjectile:
	for arrow in _projectile_pool:
		if not arrow.visible:
			return arrow
			
	var arrow = _create_projectile()
	_projectile_pool.append(arrow)
	return arrow
	
func _create_projectile() -> BaseProjectile:
	var arrow = preload("res://entity/projectile/boulder/boulder.tscn").instance()
	arrow.speed = 36
	arrow.connect("hit", self ,"_projectile_hit")
	
	var last_index = get_tree().get_root().get_child_count() - 1
	get_tree().get_root().get_child(last_index).add_child(arrow)
	return arrow
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_attacking:
		return
		
	if not is_instance_valid(attack_to):
		is_attacking = false
		return
		
	if firing_delay.is_stopped():
		perform_attack()
		firing_delay.wait_time = attack_delay
		firing_delay.start()
		
	var enemy_pos :Vector3 = to_local(attack_to.global_transform.origin)
	var to = Vector3(enemy_pos.x, translation.y, enemy_pos.z)
	
	var dis = translation.distance_squared_to(to)
	if dis < 10.0:
		return
		
	var _transform :Transform = base.transform.looking_at(translation.direction_to(to) * 100, Vector3.UP)
	base.transform = base.transform.interpolate_with(_transform, 5 * delta)
	
func perform_attack():
	audio_stream_player_3d.stream = preload("res://assets/sound/arrow_fly.wav")
	audio_stream_player_3d.play()
	
	animation_player.play("firing")
	
func _on_animation_projectile_release():
	if not is_instance_valid(attack_to):
		is_attacking = false
		return
		
	var arrow = _get_projectile()
	arrow.translation = position_3d.global_transform.origin
	arrow.accuration = 1.0
	
	area_damage.translation = attack_to.global_transform.origin
	
	if attack_to.has_method("get_prediction_path"):
		arrow.target = attack_to.get_prediction_path()
	else:
		arrow.target = attack_to.global_transform.origin
		
	arrow.fire()
	
func _projectile_hit():
	if not is_instance_valid(attack_to):
		is_attacking = false
		return
		
	if attack_to.is_dead:
		is_attacking = false
		return
		
	if not is_master:
		return
		
	for body in area_damage.get_overlapping_bodies():
		if body == self:
			continue
			
		if body is BaseBuilding or body is BaseUnit:
			if body.team != team:
				body.take_damage(attack_damage)
				
func _on_trebuchet_turret_tree_exiting():
	for i in _projectile_pool:
		i.queue_free()
