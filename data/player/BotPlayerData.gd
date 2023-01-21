extends PlayerData
class_name BotPlayerData

const difficulty_easy = 0
const difficulty_medium = 1
const difficulty_hard = 2
const difficulty_insane = 3

export var bot_difficulty :int = difficulty_easy

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	bot_difficulty = data["bot_difficulty"]
	
func to_dictionary() -> Dictionary:
	var data : Dictionary = .to_dictionary()
	data["bot_difficulty"] = bot_difficulty
	return data
	
