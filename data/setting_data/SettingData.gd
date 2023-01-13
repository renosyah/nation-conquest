extends BaseData
class_name SettingData

export var is_sfx_mute :bool = false

func from_dictionary(data : Dictionary):
	is_sfx_mute = data["is_sfx_mute"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["is_sfx_mute"] = is_sfx_mute
	return data
	
