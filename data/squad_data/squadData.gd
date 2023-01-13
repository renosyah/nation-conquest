extends BaseData
class_name SquadData

const squad_scene = preload("res://entity/squad/squad.tscn")

export var player_id :int
export var squad_name :String
export var squad_description :String
export var price :int
export var requirement_ids :Array = []
export var node_name :String
export var network_master :int
export var position :Vector3
export var unit :Resource
export var icon :Resource = preload("res://assets/ui/icon/squad_icon/icon_empty.png")
export var team :int = 0
export var color :Color = Color.white
export var max_unit :int = 8
export var formation_space :int = 1
export var is_selectable :bool = false

func from_dictionary(data : Dictionary):
	player_id = data["player_id"]
	squad_name = data["squad_name"]
	squad_description = data["squad_description"]
	price = data["price"]
	requirement_ids = data["requirement_ids"]
	node_name = data["node_name"]
	network_master = data["network_master"]
	position = data["position"]
	unit = load(data["unit"])
	icon = load(data["icon"])
	team = data["team"]
	color = data["color"]
	max_unit = data["max_unit"]
	formation_space = data["formation_space"]
	is_selectable = data["is_selectable"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["player_id"] = player_id
	data["squad_name"] = squad_name
	data["squad_description"] = squad_description
	data["price"] = price
	data["requirement_ids"] = requirement_ids
	data["node_name"] = node_name
	data["network_master"] = network_master
	data["position"] = position
	data["unit"] = unit.resource_path
	data["icon"] = icon.resource_path
	data["team"] = team
	data["color"] = color
	data["max_unit"] = max_unit
	data["formation_space"] = formation_space
	data["is_selectable"] = is_selectable
	return data
	
func spawn(parent :Node) -> Squad:
	var squad = squad_scene.instance()
	squad.player_id = player_id
	squad.unit = unit
	squad.team = team
	squad.color = color
	squad.max_unit = max_unit
	squad.formation_space = formation_space
	squad.is_selectable = is_selectable
	squad.name = node_name
	squad.set_network_master(network_master)
	parent.add_child(squad)
	return squad
