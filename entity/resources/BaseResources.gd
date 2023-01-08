extends StaticBody
class_name BaseResources

enum type_resource_enum { none,wood,food,stone }

onready var rng :RandomNumberGenerator = RandomNumberGenerator.new()
export(type_resource_enum) var type_resource = type_resource_enum.none
export var amount :int = 1
