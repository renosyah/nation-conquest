extends BaseData
class_name BuildingData

export var building_name :String
export var building_description :String
export var node_name :String
export var network_master :int
export var building :Resource
export var icon :Resource
export var team :int = 0
export var color :Color = Color.white
export var hp :int = 500
export var max_hp :int = 500
export var building_time :int = 10

func from_dictionary(data : Dictionary):
	building_name = data["building_name"]
	building_description = data["building_description"]
	node_name = data["node_name"]
	network_master = data["network_master"]
	building = load(data["building"])
	icon = load(data["icon"])
	team = data["team"]
	color = data["color"]
	hp = data["hp"]
	max_hp = data["max_hp"]
	building_time = data["building_time"]

func to_dictionary() -> Dictionary :
	var data = {}
	data["building_name"] = building_name
	data["building_description"] = building_description
	data["node_name"] = node_name
	data["network_master"] = network_master
	data["building"] = building.resource_path
	data["icon"] = icon.resource_path
	data["team"] = team
	data["color"] = color
	data["hp"] = hp
	data["max_hp"] = max_hp
	data["building_time"] = building_time
	return data
	
func spawn(parent :Node) -> BaseBuilding:
	var build = building.instance()
	build.team = team
	build.color = color
	build.name = node_name
	build.hp = hp
	build.max_hp = max_hp
	build.building_time = building_time
	build.set_network_master(network_master)
	parent.add_child(build)
	return build
