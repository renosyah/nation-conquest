extends Node
class_name SaveLoad

const prefix = "user://"

static func save(_filename: String, _data):
	var file = File.new()
	file.open(prefix + _filename, File.WRITE)
	file.store_var(_data, true)
	file.close()

static func load_save(_filename : String):
	var file = File.new()
	if file.file_exists(prefix + _filename):
		file.open(prefix + _filename, File.READ)
		var _data = file.get_var(true)
		file.close()
		return _data
	return null

static func delete_save(_filename : String):
	var dir = Directory.new()
	dir.remove(prefix + _filename)
