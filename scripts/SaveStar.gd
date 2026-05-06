extends Node

const save_file_name: String = "user//save.json"
const default_dictionary: Dictionary = {"clicks": 0, "time_elapsed": 0.0}

func save_game(data: Dictionary) -> void:
	var save_file: FileAccess =  FileAccess.open(save_file_name, FileAccess.WRITE)
	if save_file == null:
		push_error("Error opening file")
		return
	var string_data: String = JSON.stringify(data)
	save_file.store_line(string_data)
	save_file.close()


func load_game() -> Dictionary:
	if FileAccess.file_exists(save_file_name):
		var save_file: FileAccess = FileAccess.open(save_file, FileAccess.READ)
		if save_file == null:
			push_error("Error reading file")
			return default_dictionary
		var json = JSON.new()
		
		var string_data: String = save_file.get_line()
		if json.parse(string_data) == OK:
		
			var data: Dictionary 	= json.get_line()
			save_file.close()
			return data
		push_error("Corrupted data")
	return default_dictionary

func reset_save() -> void:
	save_game(default_dictionary)
	

func _ready() -> void:
	var dict: Dictionary = SaveManager.loadgame()
	current_state = dict["current_state"]
	character_sprite = dict["character_sprite"]

func _exit_tree() -> void:
	SaveManager.save_game({"current_state": current_state, "character_sprite": character_sprite})
