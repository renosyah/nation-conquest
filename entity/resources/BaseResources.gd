extends StaticBody
class_name BaseResources

enum type_resource_enum { none,wood,food,stone }

var rng :RandomNumberGenerator
export(type_resource_enum) var type_resource = type_resource_enum.none
export var amount :int = 1
