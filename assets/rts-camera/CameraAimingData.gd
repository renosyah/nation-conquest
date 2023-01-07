extends Node
class_name CameraAimingData

var rid :RID
var collider_id :int
var collider # body : static, rigit & kinematik
var normal :Vector3
var position :Vector3
var shape # ??
var distance :float

func from_dictionary(dict :Dictionary):
	rid = dict["rid"]
	collider_id = dict["collider_id"]
	collider = dict["collider"]
	normal = dict["normal"]
	position = dict["position"]
	shape = dict["shape"]
