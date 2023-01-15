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
	player.player_name = RandomNameGenerator.generate()
	player.player_color = Color(randf(), randf(), randf(), 1)
	player.player_team = 1
	
	#player.load_data(player_save_file)
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
	
