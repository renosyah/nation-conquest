extends Node

################################################################
# sound
const is_dekstop =  ["Server", "Windows", "WinRT", "X11"]
onready var sound_amplified :float = 5.0 if OS.get_name() in is_dekstop else 10.0

################################################################
# player
const player_save_file = "player.data"
onready var player :PlayerData = PlayerData.new()

################################################################

func _ready():
	setup_transition()
	
	var player_data = SaveLoad.load_save(player_save_file)
	if player_data == null:
		player.player_name = RandomNameGenerator.generate()
		player.player_color = Color(Utils.COLORS[rand_range(0, Utils.COLORS.size())])
		player.player_team = 1
		player.save_data(player_save_file)
		
	else:
		player.load_data(player_save_file)
	
################################################################
# setting
signal on_setting_update

var setting_data :SettingData = SettingData.new()
const player_setting_data_file = "player_setting_data.data"

func load_setting():
	var setting = SaveLoad.load_save(player_setting_data_file)
	if setting == null:
		return
		
	setting_data.from_dictionary(setting)
	
func apply_setting_data():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), setting_data.is_sfx_mute)
	setting_data.save_data(player_setting_data_file)
	
	emit_signal("on_setting_update")
	
################################################################
# bots
onready var bots :Array = []

func create_bot(random_team :bool = false, unused_color:Array = [], bot_difficulty :int = BotPlayerData.difficulty_easy) -> NetworkPlayer:
	var _color :Array = unused_color if not unused_color.empty() else Utils.COLORS.duplicate()
	var bot :BotPlayerData = BotPlayerData.new()
	bot.player_name =  RandomNameGenerator.generate() + " (Bot)"
	bot.player_team = int(rand_range(-69, -100)) if random_team else 1
	bot.player_color = Color(_color[rand_range(0, _color.size())])
	bot.bot_difficulty = bot_difficulty
	
	var network_bot = NetworkPlayer.new()
	network_bot.player_network_unique_id = int(rand_range(-69, -100))
	network_bot.player_name = bot.player_name
	network_bot.extra = bot.to_dictionary()
	
	return network_bot
	
################################################################
var transition :CanvasLayer
var game_transition :CanvasLayer

func setup_transition():
	transition = preload("res://assets/ui/loading/scene_transition.tscn").instance()
	add_child(transition)
	
	game_transition = preload("res://assets/ui/loading/game_transition.tscn").instance()
	add_child(game_transition)
	
func change_scene(scene :String):
	transition.change_scene(scene)

func change_to_game_scene(scene :String):
	game_transition.change_scene(scene)

func hide_game_transition():
	game_transition.hide_transition()















