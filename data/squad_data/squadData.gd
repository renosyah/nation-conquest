extends BaseData
class_name SquadData

const squad_scene = preload("res://entity/squad/squad.tscn")

export var node_name :String
export var network_master :int
export var unit :Resource
export var team :int = 0
export var color :Color = Color.white
export var max_unit :int = 15
export var formation_space :int = 1

func from_dictionary(data : Dictionary):
	node_name = data["node_name"]
	network_master = data["network_master"]
	unit = load(data["unit"])
	team = data["team"]
	color = data["color"]
	max_unit = data["max_unit"]
	formation_space = data["formation_space"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["node_name"] = node_name
	data["network_master"] = network_master
	data["unit"] = unit.resource_path
	data["team"] = team
	data["color"] = color
	data["max_unit"] = max_unit
	data["formation_space"] = formation_space
	return data
	
func spawn(parent :Node) -> Squad:
	var squad = squad_scene.instance()
	squad.unit = unit
	squad.team = team
	squad.color = color
	squad.max_unit = max_unit
	squad.formation_space = formation_space
	squad.name = node_name
	squad.set_network_master(network_master)
	parent.add_child(squad)
	return squad
