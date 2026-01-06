extends RefCounted
class_name SaveSystem

# Save and load system for levels

static func save_level(board: Array, aliens: Array, infected: Array, board_size: int, custom_name: String = "") -> String:
	# Create a save data structure
	var save_data = {
		"board_size": board_size,
		"board": board,
		"aliens": aliens,
		"infected": infected,
		"version": "1.0"
	}
	
	# Get level name
	var level_name = custom_name if custom_name != "" else "level_" + str(Time.get_unix_time_from_system())
	
	# Save to file
	var file = FileAccess.open("user://levels/" + level_name + ".json", FileAccess.WRITE)
	if file:
		# Create directory if it doesn't exist
		DirAccess.open("user://").make_dir_recursive("levels")
		file.store_string(JSON.stringify(save_data))
		file.close()
		return level_name
	else:
		return ""

static func load_level(filename: String = "") -> Dictionary:
	var file_to_load = filename
	
	# If no specific file, get the most recent one
	if file_to_load == "":
		var files = list_level_files()
		if files.size() > 0:
			files.sort()
			file_to_load = files[-1]
		else:
			return {"success": false, "error": "No se encontraron niveles guardados"}
	
	var file = FileAccess.open("user://levels/" + file_to_load, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var save_data = json.data
			return {
				"success": true,
				"board_size": save_data.get("board_size", 6),
				"board": save_data.get("board", []),
				"aliens": save_data.get("aliens", []),
				"infected": save_data.get("infected", []),
				"filename": file_to_load.get_basename()
			}
		else:
			return {"success": false, "error": "Error al parsear el archivo de nivel"}
	else:
		return {"success": false, "error": "Error al leer el archivo de nivel"}

static func list_level_files() -> Array:
	var files = []
	var dir = DirAccess.open("user://levels/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				files.append(file_name)
			file_name = dir.get_next()
	
	return files

static func list_levels() -> Array:
	# List all available levels
	var level_names = []
	var files = list_level_files()
	
	for file_name in files:
		level_names.append(file_name.get_basename())
	
	level_names.sort()
	return level_names
