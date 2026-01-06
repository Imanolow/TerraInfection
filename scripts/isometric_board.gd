extends Node2D

enum BoardSize { SIZE_4x4 = 4, SIZE_5x5 = 5, SIZE_6x6 = 6, SIZE_7x7 = 7, SIZE_8x8 = 8, SIZE_9x9 = 9 }

@export var board_size: BoardSize = BoardSize.SIZE_5x5

var grid_width: int
var grid_height: int
const TILE_WIDTH = 120.0  # Width of isometric tile
const TILE_HEIGHT = 60.0  # Height of isometric tile

var tiles: Dictionary = {}  # Store tile data by position (x, y)
var hovered_tile = null  # Currently hovered tile position
var terrains: Dictionary = {}  # Terrain definitions
var selected_terrain: String = "HIERBA"  # Currently selected terrain
var lava_timers: Dictionary = {}  # Track lava tiles with timers

func _ready():
	load_terrains()
	update_board_size()
	generate_board()

func load_terrains():
	var terrain_script = load("res://scripts/terrains.gd").new()
	terrains = terrain_script.TERRAINS

func update_board_size():
	grid_width = int(board_size)
	grid_height = int(board_size)
	tiles.clear()
	hovered_tile = null

func generate_board():
	# Create a NxN grid of isometric tiles
	for y in range(grid_height):
		for x in range(grid_width):
			var tile_pos = Vector2(x, y)
			var world_pos = grid_to_world(x, y)
			tiles[tile_pos] = {
				"grid_pos": tile_pos,
				"world_pos": world_pos,
				"hovered": false,
				"terrain": "HIERBA"
			}

func grid_to_world(x: int, y: int) -> Vector2:
	# Isometric projection: convert grid coordinates to world coordinates
	# Tiles are perfectly aligned without gaps
	var iso_x = (x - y) * TILE_WIDTH * 0.5
	var iso_y = (x + y) * TILE_HEIGHT * 0.5
	return Vector2(iso_x, iso_y) + Vector2(960.0, 200.0)  # Center on screen

func _process(_delta):
	update_hover()

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if hovered_tile != null:
			apply_terrain_to_tile(hovered_tile, selected_terrain)
			queue_redraw()

func set_board_size(new_size: BoardSize) -> void:
	board_size = new_size
	update_board_size()
	generate_board()
	queue_redraw()

func set_selected_terrain(terrain_key: String) -> void:
	if terrain_key in terrains:
		selected_terrain = terrain_key

func apply_terrain_to_tile(tile_pos: Vector2, terrain_key: String) -> void:
	if tile_pos not in tiles or terrain_key not in terrains:
		return
	
	tiles[tile_pos]["terrain"] = terrain_key
	
	# Update lava timers before applying new effects
	update_lava_timers()
	
	# Apply terrain effects to adjacent tiles
	apply_terrain_effects(tile_pos, terrain_key)

func apply_terrain_effects(tile_pos: Vector2, terrain_key: String) -> void:
	var x = int(tile_pos.x)
	var y = int(tile_pos.y)
	var adjacent = get_adjacent_tiles(x, y)
	
	match terrain_key:
		"ROCA":
			# Genera 1 Árido adyacente aleatorio
			var valid_tiles = []
			for adj_pos in adjacent:
				if tiles[adj_pos]["terrain"] == "HIERBA":
					valid_tiles.append(adj_pos)
			
			if valid_tiles.size() > 0:
				valid_tiles.shuffle()
				tiles[valid_tiles[0]]["terrain"] = "ARIDO"
		
		"CRISTAL":
			# Genera 2 Áridos adyacentes aleatorios
			var valid_tiles = []
			for adj_pos in adjacent:
				if tiles[adj_pos]["terrain"] == "HIERBA":
					valid_tiles.append(adj_pos)
			
			valid_tiles.shuffle()
			for i in range(min(2, valid_tiles.size())):
				tiles[valid_tiles[i]]["terrain"] = "ARIDO"
		
		"LAGO":
			# Genera 4 tiles de agua alrededor
			var water_tiles = []
			for adj_pos in adjacent:
				if tiles[adj_pos]["terrain"] == "HIERBA":
					water_tiles.append(adj_pos)
			
			water_tiles.shuffle()
			for i in range(min(4, water_tiles.size())):
				tiles[water_tiles[i]]["terrain"] = "AGUA"
		
		"GRANJA":
			# Convierte adyacentes en campos
			for adj_pos in adjacent:
				if tiles[adj_pos]["terrain"] == "HIERBA":
					tiles[adj_pos]["terrain"] = "CAMPO"
		
		"INFECTADA":
			# Convierte adyacentes en árido
			for adj_pos in adjacent:
				if tiles[adj_pos]["terrain"] != "AGUA":
					tiles[adj_pos]["terrain"] = "ARIDO"
		
		"BOSQUE":
			# Si hay 2+ bosques adyacentes (totalizando 3+), generar un claro
			var bosque_adyacentes = 0
			var all_bosque_neighbors = []
			
			for adj_pos in adjacent:
				if tiles[adj_pos]["terrain"] == "BOSQUE":
					bosque_adyacentes += 1
					# Recolectar adyacentes de estos bosques
					var bosque_x = int(adj_pos.x)
					var bosque_y = int(adj_pos.y)
					var bosque_adj = get_adjacent_tiles(bosque_x, bosque_y)
					for bosque_neighbor in bosque_adj:
						if bosque_neighbor not in all_bosque_neighbors:
							all_bosque_neighbors.append(bosque_neighbor)
			
			# Si hay 2+ bosques adyacentes, generar claro en tile HIERBA
			if bosque_adyacentes >= 2:
				var valid_claro = []
				for pos in all_bosque_neighbors:
					if tiles[pos]["terrain"] == "HIERBA":
						valid_claro.append(pos)
				
				# Si no hay HIERBA, intentar convertir CAMPO o CLARO ya existente
				if valid_claro.size() == 0:
					for pos in all_bosque_neighbors:
						if tiles[pos]["terrain"] != "AGUA" and tiles[pos]["terrain"] != "LAVA" and tiles[pos]["terrain"] != "BOSQUE":
							valid_claro.append(pos)
				
				if valid_claro.size() > 0:
					valid_claro.shuffle()
					tiles[valid_claro[0]]["terrain"] = "CLARO"
		
		"LAVA":
			# Inicia timer de 3 turnos para convertir adyacentes
			lava_timers[tile_pos] = {"turns": 3, "adjacent": adjacent}
		
		"HIELO":
			# TODO: Se derrite cerca de lava
			pass

func get_adjacent_tiles(x: int, y: int) -> Array:
	var adjacent = []
	# Isometric tiles have 8 neighbors
	var directions = [
		Vector2(x + 1, y),
		Vector2(x - 1, y),
		Vector2(x, y + 1),
		Vector2(x, y - 1),
		Vector2(x + 1, y - 1),
		Vector2(x - 1, y + 1),
		Vector2(x + 1, y + 1),
		Vector2(x - 1, y - 1)
	]
	
	for dir in directions:
		if dir in tiles:
			adjacent.append(dir)
	
	return adjacent

func update_hover():
	var mouse_pos = get_global_mouse_position()
	var new_hovered = null
	
	# Check which tile the mouse is over
	for tile_pos in tiles.keys():
		if is_point_in_tile(mouse_pos, tile_pos):
			new_hovered = tile_pos
			break
	
	# Update hover state
	if new_hovered != hovered_tile:
		if hovered_tile != null:
			tiles[hovered_tile]["hovered"] = false
		hovered_tile = new_hovered
		if hovered_tile != null:
			tiles[hovered_tile]["hovered"] = true
		queue_redraw()

func update_lava_timers() -> void:
	var timers_to_remove = []
	
	for lava_pos in lava_timers.keys():
		lava_timers[lava_pos]["turns"] -= 1
		
		if lava_timers[lava_pos]["turns"] <= 0:
			# Aplicar efecto de lava después de 3 turnos
			var adjacent = lava_timers[lava_pos]["adjacent"]
			for adj_pos in adjacent:
				if adj_pos in tiles and tiles[adj_pos]["terrain"] not in ["AGUA", "LAVA"]:
					tiles[adj_pos]["terrain"] = "ROCA"
			
			timers_to_remove.append(lava_pos)
	
	# Limpiar timers completados
	for lava_pos in timers_to_remove:
		lava_timers.erase(lava_pos)
	
	queue_redraw()

func is_point_in_tile(point: Vector2, tile_pos: Vector2) -> bool:
	# Get the world position of the tile
	var tile_center = tiles[tile_pos]["world_pos"]
	
	# Create the four vertices of the diamond (isometric square)
	var half_w = TILE_WIDTH * 0.5
	var half_h = TILE_HEIGHT * 0.5
	
	var top = tile_center + Vector2(0.0, -half_h)
	var right = tile_center + Vector2(half_w, 0.0)
	var bottom = tile_center + Vector2(0.0, half_h)
	var left = tile_center + Vector2(-half_w, 0.0)
	
	# Check if point is inside the diamond using cross products
	return (is_point_in_triangle(point, tile_center, top, right) or
			is_point_in_triangle(point, tile_center, right, bottom) or
			is_point_in_triangle(point, tile_center, bottom, left) or
			is_point_in_triangle(point, tile_center, left, top))

func is_point_in_triangle(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var d1 = compute_cross_product(p, a, b)
	var d2 = compute_cross_product(p, b, c)
	var d3 = compute_cross_product(p, c, a)
	
	var has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
	var has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)
	
	return not (has_neg and has_pos)

func compute_cross_product(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)

func _draw():
	# Draw all tiles (fill and base outline)
	for tile_pos in tiles.keys():
		draw_tile_fill(tile_pos)
	
	# Draw hovered tile outline on top
	if hovered_tile != null:
		draw_tile_outline(hovered_tile, Color.YELLOW, 3.0)

func draw_tile_fill(tile_pos: Vector2):
	var tile_data = tiles[tile_pos]
	var world_pos = tile_data["world_pos"]
	var half_w = TILE_WIDTH * 0.5
	var half_h = TILE_HEIGHT * 0.5
	
	# Create diamond vertices
	var top = world_pos + Vector2(0.0, -half_h)
	var right = world_pos + Vector2(half_w, 0.0)
	var bottom = world_pos + Vector2(0.0, half_h)
	var left = world_pos + Vector2(-half_w, 0.0)
	
	var vertices = PackedVector2Array([top, right, bottom, left])
	
	# Get terrain color
	var terrain_key = tile_data["terrain"]
	var color = Color.DARK_GRAY
	if terrain_key in terrains:
		var gradient = terrains[terrain_key].get("gradient", [Color.DARK_GRAY, Color.DARK_GRAY])
		color = gradient[0]  # Use first color from gradient
	
	# Draw tile fill
	draw_colored_polygon(vertices, color)
	
	# Draw base outline (white)
	var outline_color = Color.WHITE
	var outline_width = 1.0
	draw_line(top, right, outline_color, outline_width)
	draw_line(right, bottom, outline_color, outline_width)
	draw_line(bottom, left, outline_color, outline_width)
	draw_line(left, top, outline_color, outline_width)

func draw_tile_outline(tile_pos: Vector2, outline_color: Color, outline_width: float):
	var tile_data = tiles[tile_pos]
	var world_pos = tile_data["world_pos"]
	var half_w = TILE_WIDTH * 0.5
	var half_h = TILE_HEIGHT * 0.5
	
	# Create diamond vertices
	var top = world_pos + Vector2(0.0, -half_h)
	var right = world_pos + Vector2(half_w, 0.0)
	var bottom = world_pos + Vector2(0.0, half_h)
	var left = world_pos + Vector2(-half_w, 0.0)
	
	# Draw outline on top
	draw_line(top, right, outline_color, outline_width)
	draw_line(right, bottom, outline_color, outline_width)
	draw_line(bottom, left, outline_color, outline_width)
	draw_line(left, top, outline_color, outline_width)
