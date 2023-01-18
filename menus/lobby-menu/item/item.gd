extends Control

signal kick
signal change_color(_data)
signal change_team(_data)

onready var team = $VBoxContainer/HBoxContainer/HBoxContainer/change_team/team 
onready var color = $VBoxContainer/HBoxContainer/HBoxContainer/change_color/color
onready var player_name = $VBoxContainer/HBoxContainer/player_name
onready var kick_player = $VBoxContainer/HBoxContainer/panel/kick_player

onready var team_container = $VBoxContainer/HBoxContainer/HBoxContainer

var data :PlayerData
var can_kick :bool
var can_change_color :bool
var can_change_team :bool

# Called when the node enters the scene tree for the first time.
func _ready():
	team.text = str(data.player_team)
	color.color = data.player_color
	
	if data.player_team == 0:
		team_container.visible = false
		
	player_name.text = data.player_name
	kick_player.visible = can_kick

func _on_kick_player_pressed():
	if not can_kick:
		return
		
	emit_signal("kick")

func _on_change_color_pressed():
	if not can_change_color:
		return
		
	data.player_color = Color(randf(), randf(), randf(), 1)
	emit_signal("change_color", data)
	
func _on_change_team_pressed():
	if not can_change_team:
		return
		
	var team :int = data.player_team + 1
	data.player_team = team if team < 5 else 1
	emit_signal("change_team", data)
