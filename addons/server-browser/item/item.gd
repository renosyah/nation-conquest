extends Control

signal join(info)

onready var _host_name = $Panel/HBoxContainer/VBoxContainer/host_name
onready var _player_slot = $Panel/HBoxContainer/VBoxContainer/player_slot
onready var _join_btn = $Panel/HBoxContainer/host_button/btn

var info = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if info.empty():
		return
		
	var maxout_player = (info.player >= info.max_player)
		
	_join_btn.disabled = maxout_player
	_join_btn.modulate = Color(0, 0.592157, 0.035294) if not maxout_player else Color.gray
	_host_name.text = info.name
	_player_slot.text =  "Player Slot : " + str(info.player) + "/" + str(info.max_player)
	
func _on_btn_pressed():
	emit_signal("join", info)
