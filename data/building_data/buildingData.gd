extends BaseData
class_name BuildingData

export var player_id :int
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
export var base_position :Vector3
export var max_distance_from_base :int
export var is_selectable :bool = false

func from_dictionary(data : Dictionary):
	player_id = data["player_id"]
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
	base_position = data["base_position"]
	max_distance_from_base = data["max_distance_from_base"]
	is_selectable = data["is_selectable"]

func to_dictionary() -> Dictionary :
	var data = {}
	data["player_id"] = player_id
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
	data["base_position"] = base_position
	data["max_distance_from_base"] = max_distance_from_base
	data["is_selectable"] = is_selectable
	return data
	
func spawn(parent :Node) -> BaseBuilding:
	var build = building.instance()
	build.player_id = player_id
	build.team = team
	build.color = color
	build.name = node_name
	build.hp = hp
	build.max_hp = max_hp
	build.building_time = building_time
	build.base_position = base_position
	build.max_distance_from_base = max_distance_from_base
	build.is_selectable = is_selectable
	build.set_network_master(network_master)
	parent.add_child(build)
	return build
