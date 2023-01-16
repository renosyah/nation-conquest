extends BaseData
class_name PlayerData

export var player_name : String = ""
export var player_team :int = 0
export var player_color :Color = Color.white

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	player_name = data["player_name"]
	player_team = data["player_team"]
	player_color = data["player_color"]
	
func to_dictionary() -> Dictionary:
	var data : Dictionary = {}
	data["player_name"] = player_name
	data["player_team"] = player_team
	data["player_color"] = player_color
	return data
	
