extends Control

signal kick
signal change_color(_data)
signal change_team(_data)
signal change_difficulty(_data)

const bot_difficulty_data :Dictionary = {
	BotPlayerData.difficulty_easy : "Bot Easy",
	BotPlayerData.difficulty_medium : "Bot Medium",
	BotPlayerData.difficulty_hard : "Bot Hard",
	BotPlayerData.difficulty_insane : "Bot Insane"
}

onready var team = $VBoxContainer/HBoxContainer/HBoxContainer/change_team/team 
onready var color = $VBoxContainer/HBoxContainer/HBoxContainer/change_color/color
onready var player_name = $VBoxContainer/HBoxContainer/VBoxContainer/player_name
onready var bot_difficulty = $VBoxContainer/HBoxContainer/VBoxContainer/bot_difficulty
onready var kick_player = $VBoxContainer/HBoxContainer/panel/kick_player

onready var team_container = $VBoxContainer/HBoxContainer/HBoxContainer
onready var team_container_color = $VBoxContainer/HBoxContainer/HBoxContainer/change_team/color
onready var can_change_color_indicator = $VBoxContainer/HBoxContainer/HBoxContainer/change_color/TextureRect

var data

var is_bot :bool
var is_host :bool
var can_kick :bool
var can_change_color :bool
var can_change_team :bool
var can_difficulty :bool

var bot_difficulty_index :int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	team.text = str(data.player_team)
	color.color = data.player_color
	
	if data.player_team == 0:
		team_container.visible = false
		
	if is_bot:
		bot_difficulty_index = data.bot_difficulty
		bot_difficulty.text = bot_difficulty_data[data.bot_difficulty]
		bot_difficulty.disabled = not can_difficulty
		
	player_name.text = data.player_name + (" (Host)" if is_host else "")
	kick_player.visible = can_kick
	
	team_container_color.visible = can_change_team
	can_change_color_indicator.visible = can_change_color
	bot_difficulty.visible = is_bot
	
func _on_kick_player_pressed():
	if not can_kick:
		return
		
	emit_signal("kick")

func _on_change_color_pressed():
	if not can_change_color:
		return
		
	data.player_color = Utils.COLORS[rand_range(0, Utils.COLORS.size())]
	emit_signal("change_color", data)
	
func _on_change_team_pressed():
	if not can_change_team:
		return
		
	var team :int = data.player_team + 1
	data.player_team = team if team < 5 else 1
	emit_signal("change_team", data)
	
func _on_bot_difficulty_pressed():
	if not is_bot:
		return
		
	bot_difficulty_index += 1
	if bot_difficulty_index > bot_difficulty_data.size() - 1:
		bot_difficulty_index = 0
		
	data.bot_difficulty = bot_difficulty_index
	
	emit_signal("change_difficulty", data)























