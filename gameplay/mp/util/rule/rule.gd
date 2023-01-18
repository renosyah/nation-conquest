extends Node
class_name MatchRule

signal wining_team(_team)

var players :Dictionary = {}
var teams :Dictionary = {}

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func start():
	timer.start()
	
func add_player(player_id :int, team :int):
	players[player_id] = {
		"player_id" :player_id,
		"team" : team,
		"lose" : false
	}
	add_team_power(team)
	
func add_team_power(team :int):
	if teams.has(team):
		teams[team] += 1
		return
	
	teams[team] = 1
	
func player_lose(player_id :int):
	if not players.has(player_id):
		return
		
	players[player_id]["lose"] = true
	remove_team_power(players[player_id]["team"])
	
func remove_team_power(team :int):
	if not teams.has(team):
		return
		
	teams[team] -= 1
	
	if teams[team] <= 0:
		teams.erase(team)
	
func _on_Timer_timeout():
	
	# only one team remain is acceptable
	if teams.size() == 1:
		emit_signal("wining_team", teams.keys()[0])
		return 
		
	timer.start()
	
	
	
	
	
	
	
	
	
