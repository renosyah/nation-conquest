extends Node
class_name NetworkConfiguration

export var ip :String = ""
export var port :int = 31400
export var network_unique_id :int = 0

func from_dictionary(data : Dictionary):
	ip = data["ip"]
	port = data["port"]
	network_unique_id = data["network_unique_id"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["ip"] = ip
	data["port"] = port
	data["network_unique_id"] = network_unique_id
	return data
	
