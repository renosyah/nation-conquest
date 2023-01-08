extends BaseGameplay

onready var color :Color = Color(randf(), randf(), randf(), 1)

onready var player_squad_holder = $player_squad_holder
onready var enemy_squad_holder = $enemy_squad_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	_ui.color = color
	
func all_player_ready():
	.all_player_ready()
	
func _on_ui_recruit_squad(_squad :SquadData):
	._on_ui_recruit_squad(_squad)
	
	_squad.node_name = GDUUID.v4()
	_squad.network_master = NetworkLobbyManager.get_id()
	_squad.color = color
	_squad.team = 1
	
	spawn_squad( _squad, Vector3(0, 15, 0), player_squad_holder.get_path())
	
func _on_ui_deploy_building(_building_data :BuildingData):
	._on_ui_deploy_building(_building_data)
	
	_building_data.color = color
	_building_data.node_name = GDUUID.v4()
	_building_data.team = 1
	_building_data.network_master = NetworkLobbyManager.get_id()
	
	on_deploying_building(_building_data)
	
################################################################
# bot

func get_invasion_spawn_pos() -> Vector3:
	return _spawn_points[rand_range(0, 3)] + Vector3(0, 15, 0)
	
func _on_attack_wave_timer_timeout():
	if enemy_squad_holder.get_child_count() > 6:
		return
		
	var squad_datas = [
		preload("res://data/squad_data/squads/pikeman_squad.tres"),
		preload("res://data/squad_data/squads/maceman_squad.tres"),
		preload("res://data/squad_data/squads/crossbowman_squad.tres"),
		preload("res://data/squad_data/squads/archer_squad.tres"),
		preload("res://data/squad_data/squads/axeman_squad.tres"),
		preload("res://data/squad_data/squads/militia_squad.tres"),
		preload("res://data/squad_data/squads/spearman_squad.tres"),
		preload("res://data/squad_data/squads/swordman_squad.tres"),
	]
	
	var squad = squad_datas[rand_range(0, squad_datas.size())].duplicate()
	squad.node_name = GDUUID.v4()
	squad.network_master = Network.PLAYER_HOST_ID
	squad.color = Color.red
	squad.team = 2
	spawn_squad(
		squad, get_invasion_spawn_pos(), enemy_squad_holder.get_path()
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
		
	var targets :Array = player_squad_holder.get_children().duplicate() + _buildings
	if targets.empty():
		return
		
	targets.shuffle()
	
	var target = targets[0]
	for s in targets:
		if not is_instance_valid(target):
			continue
			
		if not is_instance_valid(s):
			continue
			
		var dis_1 = target.translation.distance_squared_to(squad.translation)
		var dis_2 = target.translation.distance_squared_to(s.translation)
		if dis_2 < dis_1:
			target = s
			
	if not is_instance_valid(target):
		return
		
	var attack_pos = target.translation.direction_to(
		squad.translation
	) * squad.combat_range
	
	squad.set_move_to(target.translation + attack_pos)
	
	
	
