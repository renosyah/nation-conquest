extends Node
class_name NetworkPlayer

const PLAYER_STATUS_NOT_READY = 0
const PLAYER_STATUS_READY = 1

export var player_network_unique_id :int = 0
export var player_name :String = ""
export var player_status :int = PLAYER_STATUS_NOT_READY
export var extra :Dictionary = {}

func from_dictionary(data : Dictionary):
	player_network_unique_id = data["player_network_unique_id"]
	player_name = data["player_name"]
	player_status = data["player_status"]
	extra = data["extra"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["player_network_unique_id"] = player_network_unique_id
	data["player_name"] = player_name
	data["player_status"] = player_status
	data["extra"] = extra
	return data
	
