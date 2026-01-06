extends RefCounted
class_name GameLogic

# Game logic, rules and processing

static func get_neighbors(row: int, col: int, board_size: int) -> Array:
	var neighbors = []
	var directions = [
		[-1, -1], [-1, 0], [-1, 1],
		[0, -1],           [0, 1],
		[1, -1],  [1, 0],  [1, 1]
	]
	
	for dir in directions:
		var new_row = row + dir[0]
		var new_col = col + dir[1]
		if new_row >= 0 and new_row < board_size and new_col >= 0 and new_col < board_size:
			neighbors.append({"row": new_row, "col": new_col})
	
	return neighbors

static func get_area_cells(row: int, col: int, size: int, board_size: int) -> Array:
	var cells = []
	var radius = size / 2.0
	
	for r in range(max(0, row - radius), min(board_size, row + radius + 1)):
		for c in range(max(0, col - radius), min(board_size, col + radius + 1)):
			cells.append({"row": r, "col": c})
	
	return cells

static func apply_terrain_rules(board: Array, auto_apply_rules: bool, console_callback: Callable, allow_arid_propagation: bool = false) -> bool:
	# Complete terrain rules system based on HTML original
	var changes_made = false
	var board_size = board.size()
	var iterations = 0
	var continue_iterations = true
	
	while continue_iterations and iterations < 25:
		continue_iterations = false
		iterations += 1
		
		# Phase 1: GRANJAS - Convert adjacent grass to fields
		for row in range(board_size):
			for col in range(board_size):
				var terrain = board[row][col]
				
				if terrain == "GRANJA":
					var neighbors = get_neighbors(row, col, board_size)
					for neighbor in neighbors:
						if board[neighbor.row][neighbor.col] == "HIERBA":
							board[neighbor.row][neighbor.col] = "CAMPO"
							changes_made = true
							continue_iterations = true
							console_callback.call("Granja: Hierba -> Campo en (%d, %d)" % [neighbor.row, neighbor.col])
							
							# Ensure water for the new field (Los campos cultivados necesitan agua adyacente)
							_ensure_water_for_field(board, neighbor.row, neighbor.col, board_size, console_callback)
				
				# Phase 2: GRANJAS INFECTADAS - Spread arid to adjacent grass/fields
				elif terrain == "INFECTADA":
					var neighbors = get_neighbors(row, col, board_size)
					for neighbor in neighbors:
						var neighbor_terrain = board[neighbor.row][neighbor.col]
						if neighbor_terrain == "HIERBA" or neighbor_terrain == "CAMPO":
							board[neighbor.row][neighbor.col] = "ARIDO"
							changes_made = true
							continue_iterations = true
							console_callback.call("Infectada: %s -> Arido en (%d, %d)" % [neighbor_terrain, neighbor.row, neighbor.col])
				
				# Phase 3: ROCAS - Generate 1 adjacent arid
				elif terrain == "ROCA":
					var neighbors = get_neighbors(row, col, board_size)
					for neighbor in neighbors:
						if board[neighbor.row][neighbor.col] == "HIERBA":
							board[neighbor.row][neighbor.col] = "ARIDO"
							changes_made = true
							continue_iterations = true
							console_callback.call("Roca: Hierba -> Arido en (%d, %d)" % [neighbor.row, neighbor.col])
							break  # Only convert one adjacent cell
				
				# Phase 4: CRISTALES - Generate 2 adjacent arids
				elif terrain == "CRISTAL":
					var neighbors = get_neighbors(row, col, board_size)
					var grass_neighbors = []
					for neighbor in neighbors:
						if board[neighbor.row][neighbor.col] == "HIERBA":
							grass_neighbors.append(neighbor)
					
					var count = min(2, grass_neighbors.size())
					for i in range(count):
						var neighbor = grass_neighbors[i]
						board[neighbor.row][neighbor.col] = "ARIDO"
						changes_made = true
						continue_iterations = true
						console_callback.call("Cristal: Hierba -> Arido en (%d, %d)" % [neighbor.row, neighbor.col])
				
				# Phase 5: LAVA - Convert adjacent grass/fields to rock (immediate in editor, timer in play)
				elif terrain == "LAVA":
					var neighbors = get_neighbors(row, col, board_size)
					for neighbor in neighbors:
						var neighbor_terrain = board[neighbor.row][neighbor.col]
						if neighbor_terrain == "HIERBA" or neighbor_terrain == "CAMPO":
							# In HTML: addTimedTransformation(r, c, TERRAINS.ROCA, 3);
							# For editor mode, apply immediately. In play mode, should use timer.
							# TODO: Implement timer system for play mode (3 turns delay)
							board[neighbor.row][neighbor.col] = "ROCA"
							changes_made = true
							continue_iterations = true
							console_callback.call("Lava: %s -> Roca en (%d, %d) (inmediato en editor)" % [neighbor_terrain, neighbor.row, neighbor.col])
		
		# Phase 6: DEPENDENCY CHECKS - Terrains that require others to exist
		for row in range(board_size):
			for col in range(board_size):
				var terrain = board[row][col]
				
				# CAMPOS require adjacent farm
				if terrain == "CAMPO":
					var neighbors = get_neighbors(row, col, board_size)
					var has_farm = false
					for neighbor in neighbors:
						if board[neighbor.row][neighbor.col] == "GRANJA":
							has_farm = true
							break
					
					if not has_farm:
						board[row][col] = "HIERBA"
						changes_made = true
						continue_iterations = true
						console_callback.call("Campo: Sin granja -> Hierba en (%d, %d)" % [row, col])
				
				# ARIDOS require source (rock/crystal/infected/lava) OR adjacent arid
				elif terrain == "ARIDO":
					var neighbors = get_neighbors(row, col, board_size)
					var has_source = false
					for neighbor in neighbors:
						var neighbor_terrain = board[neighbor.row][neighbor.col]
						if neighbor_terrain in ["ARIDO", "ROCA", "CRISTAL", "INFECTADA", "LAVA"]:
							has_source = true
							break
					
					# If no source, convert to grass
					if not has_source:
						board[row][col] = "HIERBA"
						changes_made = true
						continue_iterations = true
						console_callback.call("Arido: Sin fuente -> Hierba en (%d, %d)" % [row, col])
					
					# Additionally, arid consumes adjacent vegetation
					# converting it also to arid (slow desert propagation)
					# Only during turn resolution, not during editing
					elif allow_arid_propagation:
						var grass_neighbors = []
						for neighbor in neighbors:
							if board[neighbor.row][neighbor.col] == "HIERBA" and randf() < 0.2:  # 20% chance per turn
								grass_neighbors.append(neighbor)
						
						if grass_neighbors.size() > 0:
							var neighbor = grass_neighbors[0]
							board[neighbor.row][neighbor.col] = "ARIDO"
							changes_made = true
							continue_iterations = true
							console_callback.call("Arido: Propagación del desierto -> Hierba en (%d, %d)" % [neighbor.row, neighbor.col])
				
				# CLAROS require adjacent forest
				elif terrain == "CLARO":
					var neighbors = get_neighbors(row, col, board_size)
					var has_forest = false
					for neighbor in neighbors:
						if board[neighbor.row][neighbor.col] == "BOSQUE":
							has_forest = true
							break
					
					if not has_forest:
						board[row][col] = "HIERBA"
						changes_made = true
						continue_iterations = true
						console_callback.call("Claro: Sin bosque -> Hierba en (%d, %d)" % [row, col])
				
				# HIELO melts near lava
				elif terrain == "HIELO":
					var neighbors = get_neighbors(row, col, board_size)
					for neighbor in neighbors:
						if board[neighbor.row][neighbor.col] == "LAVA":
							board[row][col] = "AGUA"
							changes_made = true
							continue_iterations = true
							console_callback.call("Hielo: Cerca de lava -> Agua en (%d, %d)" % [row, col])
							break
		
		# Phase 7: FOREST RULE - Every 3 forests create 1 clear
		var forest_count = 0
		var clear_count = 0
		
		for row in range(board_size):
			for col in range(board_size):
				if board[row][col] == "BOSQUE":
					forest_count += 1
				elif board[row][col] == "CLARO":
					clear_count += 1
		
		var needed_clears = floor(forest_count / 3.0) - clear_count
		if needed_clears > 0:
			# Find grass cells adjacent to forests
			var candidate_cells = []
			for row in range(board_size):
				for col in range(board_size):
					if board[row][col] == "HIERBA":
						var neighbors = get_neighbors(row, col, board_size)
						for neighbor in neighbors:
							if board[neighbor.row][neighbor.col] == "BOSQUE":
								candidate_cells.append({"row": row, "col": col})
								break
			
			# Convert needed amount
			var conversions = min(needed_clears, candidate_cells.size())
			for i in range(conversions):
				var cell = candidate_cells[i]
				board[cell.row][cell.col] = "CLARO"
				changes_made = true
				continue_iterations = true
				console_callback.call("Bosque: Hierba -> Claro en (%d, %d) (regla 3:1)" % [cell.row, cell.col])
		
		if not auto_apply_rules:
			break
	
	if iterations >= 25:
		console_callback.call("Advertencia: Se alcanzó el límite de iteraciones en las reglas de terreno")
	
	return changes_made

static func apply_alien_transformations(board: Array, aliens: Array, console_callback: Callable):
	# Apply alien transformation abilities during turn processing
	var board_size = board.size()
	
	for row in range(board_size):
		for col in range(board_size):
			if aliens[row][col] != "":
				var alien_type = aliens[row][col]
				var terrain = board[row][col]
				
				match alien_type:
					"INFECTADOR":
						# Transform farm to infected farm
						if terrain == "GRANJA":
							board[row][col] = "INFECTADA"
							console_callback.call("Infectador: Granja -> Infectada en (%d, %d)" % [row, col])
					
					"PETRIFICADOR":
						# Transform water to rock (immediate in editor, timed in play)
						if terrain == "AGUA":
							board[row][col] = "ROCA"
							console_callback.call("Petrificador: Agua -> Roca en (%d, %d)" % [row, col])
					
					"REGENERADOR":
						# Transform arid to grass
						if terrain == "ARIDO":
							board[row][col] = "HIERBA"
							console_callback.call("Regenerador: Arido -> Hierba en (%d, %d)" % [row, col])
					
					"CONGELADOR":
						# Transform water to ice
						if terrain == "AGUA":
							board[row][col] = "HIELO"
							console_callback.call("Congelador: Agua -> Hielo en (%d, %d)" % [row, col])
					
					"PURIFICADOR":
						# Transform infected farm to farm
						if terrain == "INFECTADA":
							board[row][col] = "GRANJA"
							console_callback.call("Purificador: Infectada -> Granja en (%d, %d)" % [row, col])
					
					"MINERO":
						# Destroy rock, converting it to grass (immune to rock damage)
						if terrain == "ROCA":
							board[row][col] = "HIERBA"
							console_callback.call("Minero: Roca -> Hierba en (%d, %d)" % [row, col])
					
					"SIMBIOTICO":
						# Generate adjacent forest from grass (if on forest terrain)
						if terrain == "BOSQUE":
							var neighbors = get_neighbors(row, col, board_size)
							for neighbor in neighbors:
								if board[neighbor.row][neighbor.col] == "HIERBA":
									board[neighbor.row][neighbor.col] = "BOSQUE"
									console_callback.call("Simbiotico: Hierba -> Bosque en (%d, %d)" % [neighbor.row, neighbor.col])
									break  # Only convert one adjacent cell per turn

static func check_alien_survival(board: Array, aliens: Array, _infected: Array, _aliens_dict: Dictionary, console_callback: Callable, kill_callback: Callable):
	# Check if aliens die due to terrain conditions
	var board_size = board.size()
	
	for row in range(board_size):
		for col in range(board_size):
			if aliens[row][col] != "":
				var alien_type = aliens[row][col]
				var terrain = board[row][col]
				var dies = false
				var death_reason = ""
				
				match alien_type:
					"HIDROFOBICO":
						if terrain == "AGUA":
							dies = true
							death_reason = "Hidrofóbico muere en agua"
					"DEVASTADOR":
						if terrain == "AGUA":
							dies = true
							death_reason = "Devastador muere en agua (débil)"
					"TOXICO":
						if terrain == "CAMPO":
							dies = true
							death_reason = "Tóxico muere en campo (débil)"
					"EXPLOSIVO":
						if terrain == "ROCA":
							dies = true
							death_reason = "Explosivo muere en roca (débil)"
					"PIROCLASTA":
						if terrain == "HIELO":
							dies = true
							death_reason = "Piroclasta muere en hielo (débil)"
					"ANFIBIO":
						# Inmune a agua y pantano
						if terrain == "AGUA" or terrain == "PANTANO":
							pass  # No muere
						elif terrain == "LAVA" or terrain == "ANULADO":
							dies = true
							death_reason = "Alien muere en " + terrain.to_lower()
					"MINERO":
						# Inmune a roca
						if terrain == "ROCA":
							pass  # No muere
						elif terrain == "LAVA" or terrain == "ANULADO":
							dies = true
							death_reason = "Alien muere en " + terrain.to_lower()
					"SIMBIOTICO":
						# Inmune a bosque
						if terrain == "BOSQUE":
							pass  # No muere
						elif terrain == "LAVA" or terrain == "ANULADO":
							dies = true
							death_reason = "Alien muere en " + terrain.to_lower()
					"REGENERADOR":
						# Inmune a árido
						if terrain == "ARIDO":
							pass  # No muere
						elif terrain == "LAVA" or terrain == "ANULADO":
							dies = true
							death_reason = "Alien muere en " + terrain.to_lower()
					"INFECTADOR":
						# Inmune a campo
						if terrain == "CAMPO":
							pass  # No muere
						elif terrain == "LAVA" or terrain == "ANULADO":
							dies = true
							death_reason = "Alien muere en " + terrain.to_lower()
					_:
						# Most aliens die in lava and anulado
						if terrain == "LAVA":
							dies = true
							death_reason = "Alien muere en lava"
						elif terrain == "ANULADO":
							dies = true
							death_reason = "Alien muere en terreno anulado"
				
				if dies:
					console_callback.call("💀 " + death_reason + " en (%d, %d)" % [row, col])
					kill_callback.call(row, col)

static func apply_alien_death_effects(row: int, col: int, alien_type: String, board: Array, aliens_dict: Dictionary, console_callback: Callable, kill_callback: Callable) -> int:
	var chain_reactions = 1
	console_callback.call("💀 %s muere en (%d, %d)" % [aliens_dict[alien_type].name, row, col])
	var board_size = board.size()
	
	match alien_type:
		"DEVASTADOR":
			# Muerte → Árido 3x3
			var affected_cells = get_area_cells(row, col, 3, board_size)
			for cell in affected_cells:
				if board[cell.row][cell.col] != "ANULADO":
					board[cell.row][cell.col] = "ARIDO"
					kill_callback.call(cell.row, cell.col)
			console_callback.call("🔥 Devastador convierte área 3x3 en Árido")
		
		"HIDROFOBICO":
			# Muerte → Terreno anulado
			board[row][col] = "ANULADO"
			console_callback.call("🚫 Hidrofóbico anula el terreno")
		
		"TOXICO":
			# Muerte → Árido 3x3 + mata granjas en área adyacente (las convierte en infectadas)
			var affected_cells = get_area_cells(row, col, 3, board_size)
			for cell in affected_cells:
				if board[cell.row][cell.col] != "ANULADO":
					board[cell.row][cell.col] = "ARIDO"
					kill_callback.call(cell.row, cell.col)
			
			# Kill adjacent farms (convert to infected farms, matching HTML killAdjacentFarms)
			var neighbors = get_neighbors(row, col, board_size)
			for neighbor in neighbors:
				if board[neighbor.row][neighbor.col] == "GRANJA":
					board[neighbor.row][neighbor.col] = "INFECTADA"
					kill_callback.call(neighbor.row, neighbor.col)
			console_callback.call("☠️ Tóxico convierte área en Árido y mata granjas adyacentes")
		
		"EXPLOSIVO":
			# Muerte → Árido 5x5
			var affected_cells = get_area_cells(row, col, 5, board_size)
			for cell in affected_cells:
				if board[cell.row][cell.col] != "ANULADO":
					board[cell.row][cell.col] = "ARIDO"
					kill_callback.call(cell.row, cell.col)
			console_callback.call("💥 Explosivo convierte área 5x5 en Árido")
		
		"PIROCLASTA":
			# Muerte → Lava 3x3
			var affected_cells = get_area_cells(row, col, 3, board_size)
			for cell in affected_cells:
				if board[cell.row][cell.col] != "ANULADO":
					board[cell.row][cell.col] = "LAVA"
					kill_callback.call(cell.row, cell.col)
			console_callback.call("🌋 Piroclasta convierte área 3x3 en Lava")
	
	return chain_reactions

static func check_game_state(infected: Array, available_aliens: Array, console_callback: Callable):
	var infected_count = 0
	var board_size = infected.size()
	var total_cells = board_size * board_size
	var available_count = 0
	
	for row in range(board_size):
		for col in range(board_size):
			if infected[row][col]:
				infected_count += 1
	
	for alien_data in available_aliens:
		available_count += alien_data.count
	
	if infected_count == total_cells:
		console_callback.call("🎉 ¡VICTORIA! Todo el tablero está infectado")
	elif available_count == 0 and infected_count < total_cells:
		console_callback.call("💀 DERROTA: Sin aliens disponibles y tablero no completamente infectado")

static func validate_level(board: Array, aliens: Array) -> Dictionary:
	# Validate that the level has aliens and interesting terrain
	var has_aliens = false
	var terrain_variety = {}
	var board_size = board.size()
	
	for row in range(board_size):
		for col in range(board_size):
			if aliens[row][col] != "":
				has_aliens = true
			
			var terrain = board[row][col]
			terrain_variety[terrain] = terrain_variety.get(terrain, 0) + 1
	
	return {
		"valid": has_aliens and terrain_variety.size() >= 3,
		"has_aliens": has_aliens,
		"terrain_variety": terrain_variety.size()
	}

# Helper function: ensure water for cultivated fields (from HTML ensureWaterForField)
static func _ensure_water_for_field(board: Array, field_row: int, field_col: int, board_size: int, console_callback: Callable):
	var neighbors = get_neighbors(field_row, field_col, board_size)
	var has_water = false
	
	# Check if field already has water or swamp adjacent
	for neighbor in neighbors:
		var neighbor_terrain = board[neighbor.row][neighbor.col]
		if neighbor_terrain == "AGUA" or neighbor_terrain == "PANTANO":
			has_water = true
			break
	
	# If no water found, convert one grass neighbor to water
	if not has_water:
		for neighbor in neighbors:
			if board[neighbor.row][neighbor.col] == "HIERBA":
				board[neighbor.row][neighbor.col] = "AGUA"
				console_callback.call("Campo: Necesita agua -> Hierba->Agua en (%d, %d)" % [neighbor.row, neighbor.col])
				break
