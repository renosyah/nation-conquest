extends Control

signal kick(_data)

onready var player_name = $VBoxContainer/HBoxContainer/VBoxContainer/player_name
onready var kick_player = $VBoxContainer/HBoxContainer/panel/kick_player

var data :NetworkPlayer
var can_kick :bool

# Called when the node enters the scene tree for the first time.
func _ready():
	player_name.text = data.player_name
	kick_player.visible = can_kick

func _on_kick_player_pressed():
	emit_signal("kick",data)

func _on_change_color_pressed():
	pass # Replace with function body.
