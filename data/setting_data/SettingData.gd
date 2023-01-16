extends BaseData
class_name SettingData

export var is_sfx_mute :bool = false
export var screen_orientation :int = 1

func from_dictionary(data : Dictionary):
	screen_orientation = data["screen_orientation"]
	is_sfx_mute = data["is_sfx_mute"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["is_sfx_mute"] = is_sfx_mute
	data["screen_orientation"] = screen_orientation
	return data
	
