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

var selected_squad :Array = []
var colors = [Color.red, Color.blue, Color.green, Color.yellow]

onready var player_squad_holder = $player_squad_holder
onready var enemy_squad_holder = $enemy_squad_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func all_player_ready():
	.all_player_ready()
	
	var spawn_pos = Vector3.UP * 15
	var player_index = 0
	
	for player in NetworkLobbyManager.get_players():
		var formation = Utils.get_formation_box(spawn_pos, 4, 8)
		for i in range(2):
			var squad = squads[rand_range(0, squads.size())]
			squad.node_name = GDUUID.v4()
			squad.network_master = player.player_network_unique_id
			squad.color = colors[player_index]
			squad.team = 1
			squad.is_selectable = player.player_network_unique_id == NetworkLobbyManager.get_id()
			spawn_squad(
				squad, player_squad_holder.get_path(),formation[i]
			)
			
		spawn_pos += Vector3(spawn_pos.x - 3, spawn_pos.y, spawn_pos.z)
		player_index += 1
	
func on_map_click(_pos :Vector3):
	.on_map_click(_pos)
	
	if selected_squad.empty():
		return
	
	var formation = Utils.get_formation_box(
		_pos, selected_squad.size(), 5
	)
	for i in range(selected_squad.size()):
		if is_instance_valid(selected_squad[i]):
			selected_squad[i].set_selected(false)
			selected_squad[i].set_move_to(formation[i], true)
			
	selected_squad.clear()
	
func on_squad_selected(_squad :Squad):
	.on_squad_selected(_squad)
	
	if _squad.get_network_master() != NetworkLobbyManager.get_id()  or _squad.team != 1:
		return
	
	var is_in_squad = selected_squad.has(_squad)
	_squad.set_selected(not is_in_squad)
	
	if is_in_squad:
		selected_squad.erase(_squad)
	else:
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
	
	if player_squad_holder.get_child_count() < 1:
		return
	
	var target :Squad = player_squad_holder.get_child(
		rand_range(0, player_squad_holder.get_child_count())
	)
	var attack_pos = target.translation.direction_to(
		squad.translation
	) * squad.combat_range
	
	squad.set_move_to(target.translation + attack_pos)
	
	
	
