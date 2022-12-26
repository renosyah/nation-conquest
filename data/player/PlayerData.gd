extends BaseData
class_name PlayerData

export var player_id : int = 0
export var player_name : String = ""
export var player_team :int = 0

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	player_id = data["player_id"]
	player_name = data["player_name"]
	player_team = data["player_team"]
	
func to_dictionary() -> Dictionary:
	var data : Dictionary = {}
	data["player_id"] = player_id
	data["player_name"] = player_name
	data["player_team"] = player_team
	return data
	
