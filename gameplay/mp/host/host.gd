extends BaseGameplay

const squads = [
	preload("res://data/squad_data/squads/pikeman_squad.tres"),
	preload("res://data/squad_data/squads/maceman_squad.tres"),
	preload("res://data/squad_data/squads/crossbowman_squad.tres"),
	preload("res://data/squad_data/squads/archer_squad.tres"),
	preload("res://data/squad_data/squads/axeman_squad.tres"),
	preload("res://data/squad_data/squads/militia_squad.tres"),
	preload("res://data/squad_data/squads/spearman_squad.tres"),
	preload("res://data/squad_data/squads/swordman_squad.tres"),
]

const squad_icons = [
	preload("res://assets/ui/icon/squad_icon/icon_squad_pikeman.png"),
	preload("res://assets/ui/icon/squad_icon/icon_squad_maceman.png"),
	preload("res://assets/ui/icon/squad_icon/icon_squad_crossbowman.png"),
	preload("res://assets/ui/icon/squad_icon/icon_squad_archer.png"),
	preload("res://assets/ui/icon/squad_icon/icon_squad_axeman.png"),
	preload("res://assets/ui/icon/squad_icon/icon_squad_man_at_arms.png"),
	preload("res://assets/ui/icon/squad_icon/icon_squad_spearman.png"),
	preload("res://assets/ui/icon/squad_icon/icon_squad_swordman.png"),
]

var selected_squad :Array = []
onready var player_squad_holder = $player_squad_holder
onready var enemy_squad_holder = $enemy_squad_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func all_player_ready():
	.all_player_ready()
	
	var spawn_pos = Vector3.UP * 15
	var player_army_size = 4
	var player_squad_size = 15
	
	for player in NetworkLobbyManager.get_players():
		var formation = Utils.get_formation_box(spawn_pos, player_army_size, 4)
		var color = Color(randf(), randf(), randf(), 1)
		for i in range(player_army_size):
			var pos = rand_range(0, squads.size())
			var squad = squads[pos]
			squad.node_name = GDUUID.v4()
			squad.network_master = player.player_network_unique_id
			squad.color = color
			squad.team = 1
			squad.icon = squad_icons[pos]
			squad.max_unit = player_squad_size
			spawn_squad(
				squad, player_squad_holder.get_path(),formation[i]
			)
			
		spawn_pos += Vector3(spawn_pos.x - 3, spawn_pos.y, spawn_pos.z)
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)
	
	if selected_squad.empty():
		return
	
	var formation = Utils.get_formation_box(
		_pos, selected_squad.size(), 5
	)
	for i in range(selected_squad.size()):
		if is_instance_valid(selected_squad[i]):
			selected_squad[i].set_move_to(formation[i], true)
			
func on_squad_selected(_squad :Squad):
	.on_squad_selected(_squad)
	
	if _squad.get_network_master() != NetworkLobbyManager.get_id()  or _squad.team != 1:
		return
		
	var is_in_squad = selected_squad.has(_squad)
	if is_in_squad:
		_squad.set_selected(false)
		_ui.on_squad_selected(_squad, false)
		selected_squad.erase(_squad)
	else:
		_squad.set_selected(true)
		_ui.on_squad_selected(_squad, true)
		selected_squad.append(_squad)
		
func on_squad_dead(_squad :Squad):
	if selected_squad.has(_squad):
		selected_squad.erase(_squad)
		
	.on_squad_dead(_squad)

func get_invasion_spawn_pos() -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(50, 60)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = _map.global_transform.origin + Vector3(posv2.x, 8, posv2.y)
	return posv3
	
func _on_attack_wave_timer_timeout():
	if enemy_squad_holder.get_child_count() > 3:
		return
		
	var squad = squads[rand_range(0, squads.size())]
	squad.node_name = GDUUID.v4()
	squad.network_master = Network.PLAYER_HOST_ID
	squad.color = Color(randf(), randf(), randf(), 1.0)
	squad.team = 2
	squad.max_unit = int(rand_range(4, 8))
	spawn_squad(
		squad, enemy_squad_holder.get_path(), get_invasion_spawn_pos()
	)
	
func _on_bot_attack_timer_timeout():
	if enemy_squad_holder.get_child_count() < 1:
		return
		
	var squads = enemy_squad_holder.get_children().duplicate()
	squads.shuffle()
		
	var squad :Squad = null
	for i in squads:
		if i.is_in_combat() or i.is_moving:
			continue
			
		squad = i
		break
		
	if not is_instance_valid(squad):
		return
	
	if player_squad_holder.get_children().empty():
		return
	
	var target :Squad = player_squad_holder.get_child(0)
	for s in player_squad_holder.get_children():
		if not is_instance_valid(target):
			continue
			
		if not is_instance_valid(s):
			continue
			
		var dis_1 = target.translation.distance_to(squad.translation)
		var dis_2 = target.translation.distance_to(s.translation)
		if dis_2 < dis_1:
			target = s
			
	if not is_instance_valid(target):
		return
		
	var attack_pos = target.translation.direction_to(
		squad.translation
	) * squad.combat_range
	
	squad.set_move_to(target.translation + attack_pos)
	
	
	
