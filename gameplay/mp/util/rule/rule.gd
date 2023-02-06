extends Node
class_name MatchRule

signal wining_team(_team)

var _players :Dictionary = {}
var _teams :Dictionary = {}
var _is_over :bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func add_player(player_id :int, team :int):
	_players[player_id] = {
		"player_id" :player_id,
		"team" : team,
		"lose" : false
	}
	_add_team_power(team)
	_is_over = false
	
func _add_team_power(team :int):
	if _teams.has(team):
		_teams[team] += 1
		return
	
	_teams[team] = 1
	
func player_lose(player_id :int):
	if not _players.has(player_id):
		return
		
	if _players[player_id]["lose"]:
		return
		
	_players[player_id]["lose"] = true
	_remove_team_power(_players[player_id]["team"])
	
func _remove_team_power(team :int):
	if not _teams.has(team):
		return
		
	_teams[team] -= 1
	
	if _teams[team] <= 0:
		_teams.erase(team)
		
	_check_wining_team()
	
func _check_wining_team():
	if _is_over:
		return
		
	# only one team remain is acceptable
	if _teams.size() == 1:
		_is_over = true
		emit_signal("wining_team", _teams.keys()[0])
	
	
	
	
	
	
	
