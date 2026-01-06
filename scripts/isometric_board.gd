extends Node2D

enum BoardSize { SIZE_4x4 = 4, SIZE_5x5 = 5, SIZE_6x6 = 6, SIZE_7x7 = 7, SIZE_8x8 = 8 }

@export var board_size: BoardSize = BoardSize.SIZE_5x5

var grid_width: int
var grid_height: int
const TILE_WIDTH = 120.0  # Width of isometric tile
const TILE_HEIGHT = 60.0  # Height of isometric tile

var tiles: Dictionary = {}  # Store tile data by position (x, y)
var hovered_tile = null  # Currently hovered tile position

func _ready():
	update_board_size()
	generate_board()

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
				"hovered": false
			}

func grid_to_world(x: int, y: int) -> Vector2:
	# Isometric projection: convert grid coordinates to world coordinates
	# Tiles are perfectly aligned without gaps
	var iso_x = (x - y) * TILE_WIDTH * 0.5
	var iso_y = (x + y) * TILE_HEIGHT * 0.5
	return Vector2(iso_x, iso_y) + Vector2(960.0, 200.0)  # Center on screen

func _process(_delta):
	update_hover()

func set_board_size(new_size: BoardSize) -> void:
	board_size = new_size
	update_board_size()
	generate_board()
	queue_redraw()

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
	
	# Draw tile fill
	var color = Color.DARK_GRAY
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
