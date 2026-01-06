extends RefCounted
class_name BoardRenderer

# Board rendering and visual management

static func render_board_complete(board: Array, aliens: Array, infected: Array, board_area: Control, terrains_dict: Dictionary, aliens_dict: Dictionary, board_size: int, cell_clicked_callback: Callable, cell_hover_callback: Callable):
	# Clear existing board cells
	for child in board_area.get_children():
		child.queue_free()
	
	# Fixed cell size for isometric diamonds (DOUBLED SIZE)
	var cell_width = 120.0  # Width of diamond (doubled from 80)
	var cell_height = 60.0  # Height of diamond (doubled from 40)
	var gap = 4.5  # Separation between cells (doubled from 3)
	
	# Calculate board center offset
	var area_size = board_area.size if board_area.size != Vector2.ZERO else Vector2(800, 600)
	var board_center_x = area_size.x / 2
	var board_center_y = area_size.y / 2 - 300  # Move board significantly higher to center it properly
	
	for row in range(board_size):
		for col in range(board_size):
			# Calculate isometric position with gap
			var iso_x = (col - row) * (cell_width / 2 + gap) + board_center_x
			var iso_y = (col + row) * (cell_height / 2 + gap * 0.5) + board_center_y
			
			# Create a diamond-shaped polygon for true isometric view
			var polygon = Polygon2D.new()
			
			# Define diamond vertices (isometric cube face)
			var vertices = PackedVector2Array([
				Vector2(0, -cell_height/2),           # Top
				Vector2(cell_width/2, 0),             # Right
				Vector2(0, cell_height/2),            # Bottom
				Vector2(-cell_width/2, 0)             # Left
			])
			
			polygon.polygon = vertices
			polygon.position = Vector2(iso_x, iso_y)
			
			# Get terrain color
			var terrain = terrains_dict[board[row][col]]
			polygon.color = terrain.gradient[0]
			
			# Add infected effect
			if infected[row][col]:
				polygon.color = Color.RED.lerp(terrain.gradient[0], 0.5)
			
			board_area.add_child(polygon)
			
			# Add alien label if present
			if aliens[row][col] != "":
				var alien_label = Label.new()
				alien_label.text = aliens_dict[aliens[row][col]].name.split(" ")[0]  # Just the emoji
				alien_label.size = Vector2(cell_width, cell_height)
				alien_label.position = Vector2(iso_x - cell_width/2, iso_y - cell_height/2)
				alien_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				alien_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				alien_label.add_theme_font_size_override("font_size", 40)  # Doubled from 20
				board_area.add_child(alien_label)
			
			# Make cells clickable with diamond-shaped area
			var button = Button.new()
			button.size = Vector2(cell_width, cell_height)
			button.position = Vector2(iso_x - cell_width/2, iso_y - cell_height/2)
			button.flat = true
			button.modulate = Color(1, 1, 1, 0.01)  # Almost transparent but clickable
			
			# Connect signals using bind() - safe approach WITH REAL POLYGON REFERENCE
			button.pressed.connect(cell_clicked_callback.bind(row, col))
			button.mouse_entered.connect(cell_hover_callback.bind(row, col, true, polygon))
			button.mouse_exited.connect(cell_hover_callback.bind(row, col, false, polygon))
			board_area.add_child(button)

static func render_board_isometric(board: Array, aliens: Array, infected: Array, board_area: Control, terrains_dict: Dictionary, aliens_dict: Dictionary):
	# Clear existing board cells
	for child in board_area.get_children():
		child.queue_free()
	
	var board_size = board.size()
	
	# Fixed cell size for isometric diamonds (DOUBLED SIZE)
	var cell_width = 120.0  # Width of diamond (doubled from 80)
	var cell_height = 60.0  # Height of diamond (doubled from 40)
	var gap = 4.5  # Separation between cells (doubled from 3)
	
	# Calculate board center offset
	var area_size = board_area.size if board_area.size != Vector2.ZERO else Vector2(800, 600)
	var board_center_x = area_size.x / 2
	var board_center_y = area_size.y / 2 - 300  # Move board significantly higher to center it properly
	
	for row in range(board_size):
		for col in range(board_size):
			# Calculate isometric position with gap
			var iso_x = (col - row) * (cell_width / 2 + gap) + board_center_x
			var iso_y = (col + row) * (cell_height / 2 + gap * 0.5) + board_center_y
			
			# Create a diamond-shaped polygon for true isometric view
			var polygon = Polygon2D.new()
			
			# Define diamond vertices (isometric cube face)
			var vertices = PackedVector2Array([
				Vector2(0, -cell_height/2),           # Top
				Vector2(cell_width/2, 0),             # Right
				Vector2(0, cell_height/2),            # Bottom
				Vector2(-cell_width/2, 0)             # Left
			])
			
			polygon.polygon = vertices
			polygon.position = Vector2(iso_x, iso_y)
			
			# Get terrain color
			var terrain = terrains_dict[board[row][col]]
			polygon.color = terrain.gradient[0]
			
			# Add infected effect
			if infected[row][col]:
				polygon.color = Color.RED.lerp(terrain.gradient[0], 0.5)
			
			board_area.add_child(polygon)
			
			# Add alien label if present
			if aliens[row][col] != "":
				var alien_label = Label.new()
				alien_label.text = aliens_dict[aliens[row][col]].name.split(" ")[0]  # Just the emoji
				alien_label.size = Vector2(cell_width, cell_height)
				alien_label.position = Vector2(iso_x - cell_width/2, iso_y - cell_height/2)
				alien_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				alien_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				alien_label.add_theme_font_size_override("font_size", 40)  # Doubled from 20
				board_area.add_child(alien_label)

static func create_board_cell_2d(row: int, col: int, cell_size_param: float, board: Array, aliens: Array, infected: Array, terrains_dict: Dictionary, aliens_dict: Dictionary, cell_clicked_callback: Callable, cell_hover_callback: Callable) -> Control:
	var cell = Control.new()
	cell.custom_minimum_size = Vector2(cell_size_param, cell_size_param)
	cell.size = Vector2(cell_size_param, cell_size_param)
	
	# Create background panel
	var panel = Panel.new()
	panel.anchors_preset = Control.PRESET_FULL_RECT
	
	# Style based on terrain
	var terrain = terrains_dict[board[row][col]]
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = terrain.gradient[0].lerp(terrain.gradient[1], 0.5)
	
	# Add infected border effect if infected
	if infected[row][col]:
		stylebox.border_width_left = 3
		stylebox.border_width_right = 3
		stylebox.border_width_top = 3
		stylebox.border_width_bottom = 3
		stylebox.border_color = Color.RED
	else:
		stylebox.border_width_left = 1
		stylebox.border_width_right = 1
		stylebox.border_width_top = 1
		stylebox.border_width_bottom = 1
		stylebox.border_color = Color.GRAY
	
	# Special terrain effects
	match board[row][col]:
		"LAVA":
			stylebox.bg_color = Color.ORANGE_RED
		"CRISTAL":
			stylebox.bg_color = Color.PLUM
		"HIELO":
			stylebox.bg_color = Color.POWDER_BLUE
		"ANULADO":
			stylebox.bg_color = Color.BLACK
			stylebox.border_color = Color.PURPLE
	
	panel.add_theme_stylebox_override("panel", stylebox)
	cell.add_child(panel)
	
	# Add alien if present
	if aliens[row][col] != "":
		var alien_label = Label.new()
		alien_label.text = aliens_dict[aliens[row][col]].name.split(" ")[0]  # Just the emoji
		alien_label.anchors_preset = Control.PRESET_CENTER
		alien_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		alien_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		alien_label.add_theme_font_size_override("font_size", max(16, int(cell_size_param * 0.5)))
		cell.add_child(alien_label)
	
	# Add click detection
	var button = Button.new()
	button.anchors_preset = Control.PRESET_FULL_RECT
	button.flat = true
	button.pressed.connect(cell_clicked_callback.bind(row, col))
	button.mouse_entered.connect(cell_hover_callback.bind(row, col, true))
	button.mouse_exited.connect(cell_hover_callback.bind(row, col, false))
	cell.add_child(button)
	
	return cell

@warning_ignore("unused_parameter")
static func handle_cell_hover_iso(row: int, col: int, hovering: bool, polygon: Polygon2D, board_area: Control):
	if not is_instance_valid(polygon):
		return
	
	if hovering:
		# Remove any existing hover first
		remove_hover_outline(polygon)
		# Create simple white outline
		create_simple_hover_outline(polygon)
	else:
		# Remove hover effect
		remove_hover_outline(polygon)

static func create_clickable_cell(row: int, col: int, iso_x: float, iso_y: float, cell_width: float, cell_height: float, board_area: Control, polygon: Polygon2D, cell_clicked_callback: Callable, cell_hover_callback: Callable):
	# Make cells clickable with diamond-shaped area
	var button = Button.new()
	button.size = Vector2(cell_width, cell_height)
	button.position = Vector2(iso_x - cell_width/2, iso_y - cell_height/2)
	button.flat = true
	button.modulate = Color(1, 1, 1, 0.01)  # Almost transparent but clickable
	
	# Connect signals using bind() - safe approach for all connections
	button.pressed.connect(cell_clicked_callback.bind(row, col))
	button.mouse_entered.connect(cell_hover_callback.bind(row, col, true, polygon))
	button.mouse_exited.connect(cell_hover_callback.bind(row, col, false, polygon))
	board_area.add_child(button)

static func create_simple_hover_outline(polygon: Polygon2D):
	# Create simple white outline around the polygon
	var outline = Line2D.new()
	outline.width = 2.0  # 2 pixel white outline
	outline.default_color = Color.WHITE
	outline.z_index = 100  # On top
	
	# Get the exact diamond points from the polygon
	var points = polygon.polygon
	for point in points:
		outline.add_point(point)
	outline.add_point(points[0])  # Close the diamond
	
	outline.position = polygon.position
	
	# Add to the same parent as the polygon
	polygon.get_parent().add_child(outline)
	
	# Store reference for removal
	polygon.set_meta("hover_outline", outline)

static func create_hover_outline_direct(polygon: Polygon2D, board_area: Control, _row: int, _col: int):
	# Create EXACT same diamond shape as the cells but ONLY outline
	var cell_width = 120.0  # Same as render_board
	var cell_height = 60.0  # Same as render_board
	
	# Create the hover outline as a Polygon2D - SAME shape as original cell
	var hover_outline = Polygon2D.new()
	hover_outline.color = Color.TRANSPARENT  # NO FILL - transparent
	
	# Create the EXACT same diamond vertices as the original cells
	var diamond_points = PackedVector2Array([
		Vector2(0, -cell_height/2),           # Top
		Vector2(cell_width/2, 0),             # Right  
		Vector2(0, cell_height/2),            # Bottom
		Vector2(-cell_width/2, 0)             # Left
	])
	hover_outline.polygon = diamond_points
	hover_outline.position = polygon.position  # SAME position as original
	hover_outline.z_index = 100  # On top
	
	# Add WHITE outline of 2 pixels
	var outline = Line2D.new()
	outline.width = 2.0  # 2 pixel outline as requested
	outline.default_color = Color.WHITE  # White outline
	outline.z_index = 101  # Above the transparent polygon
	
	# Add the diamond points to the line (close the shape)
	for point in diamond_points:
		outline.add_point(point)
	outline.add_point(diamond_points[0])  # Close the diamond
	
	outline.position = polygon.position  # Same position
	
	# Add both to board area
	board_area.add_child(hover_outline)
	board_area.add_child(outline)
	
	# Store BOTH references for removal
	polygon.set_meta("hover_outline", hover_outline)
	polygon.set_meta("hover_line", outline)

static func remove_hover_outline(polygon: Polygon2D):
	# Remove hover effect
	if is_instance_valid(polygon) and polygon.has_meta("hover_outline"):
		var outline = polygon.get_meta("hover_outline")
		if is_instance_valid(outline):
			outline.queue_free()
		polygon.remove_meta("hover_outline")
