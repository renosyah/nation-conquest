extends Control

signal kick(_data)
signal change_color(_data)

onready var team = $VBoxContainer/HBoxContainer/change_color/team
onready var color = $VBoxContainer/HBoxContainer/change_color/color
onready var player_name = $VBoxContainer/HBoxContainer/VBoxContainer/player_name
onready var kick_player = $VBoxContainer/HBoxContainer/panel/kick_player

var data :PlayerData
var can_kick :bool

# Called when the node enters the scene tree for the first time.
func _ready():
	team.text = str(data.player_team)
	color.color = data.player_color
	player_name.text = data.player_name
	kick_player.visible = can_kick

func _on_kick_player_pressed():
	emit_signal("kick",data)

func _on_change_color_pressed():
	data.player_color = Color(randf(), randf(), randf(), 1)
	emit_signal("change_color", data)
