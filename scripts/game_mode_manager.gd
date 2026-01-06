extends RefCounted
class_name GameModeManager

# Game mode management and play logic

static func setup_play_mode_aliens() -> Array:
	return [
		{"type": "DEVASTADOR", "count": 2},
		{"type": "HIDROFOBICO", "count": 1},
		{"type": "TOXICO", "count": 1},
		{"type": "INFECTADOR", "count": 2},
		{"type": "REGENERADOR", "count": 1}
	]

static func setup_test_mode_aliens() -> Array:
	return [
		{"type": "DEVASTADOR", "count": 2},
		{"type": "HIDROFOBICO", "count": 1},
		{"type": "TOXICO", "count": 1},
		{"type": "EXPLOSIVO", "count": 1},
		{"type": "INFECTADOR", "count": 2},
		{"type": "REGENERADOR", "count": 1},
		{"type": "PURIFICADOR", "count": 1}
	]

static func render_alien_list(alien_game_list: Control, available_aliens: Array, aliens_dict: Dictionary, select_callback: Callable):
	# Clear existing alien list
	for child in alien_game_list.get_children():
		child.queue_free()
	
	# Create alien selection buttons for play mode
	for i in range(available_aliens.size()):
		var alien_data = available_aliens[i]
		if alien_data.count > 0:
			var alien_info = aliens_dict[alien_data.type]
			var button = Button.new()
			button.text = "%s (%d)" % [alien_info.name, alien_data.count]
			button.custom_minimum_size = Vector2(0, 40)
			
			# Style the button
			var stylebox = StyleBoxFlat.new()
			stylebox.bg_color = Color(0.102, 0.102, 0.18)
			stylebox.border_width_left = 1
			stylebox.border_width_right = 1
			stylebox.border_width_top = 1
			stylebox.border_width_bottom = 1
			stylebox.border_color = Color(0.059, 0.204, 0.376)
			button.add_theme_stylebox_override("normal", stylebox)
			
			button.pressed.connect(select_callback.bind(i))
			alien_game_list.add_child(button)

static func update_alien_selection_visual(alien_game_list: Control, selected_index: int):
	var children = alien_game_list.get_children()
	for i in range(children.size()):
		if i == selected_index:
			children[i].modulate = Color(0.059, 1, 0.533)  # Green highlight
		else:
			children[i].modulate = Color.WHITE

static func update_stats_display(stats_container: Control, board: Array, infected: Array, available_aliens: Array, _turn: int, chain_reactions: int):
	var infected_count = 0
	var total_cells = board.size() * board.size()
	
	for row in range(board.size()):
		for col in range(board.size()):
			if infected[row][col]:
				infected_count += 1
	
	var available_count = 0
	for alien_data in available_aliens:
		available_count += alien_data.count
	
	# Update stats labels
	stats_container.get_node("Level").text = "Nivel: %d" % 1
	stats_container.get_node("Infected").text = "Infectadas: %d/%d" % [infected_count, total_cells]
	stats_container.get_node("Available").text = "Aliens Restantes: %d" % available_count
	stats_container.get_node("Reactions").text = "Reacciones: %d" % chain_reactions

static func check_game_state(board: Array, infected: Array, available_aliens: Array, show_info_callback: Callable):
	var infected_count = 0
	var total_cells = board.size() * board.size()
	var available_count = 0
	
	for row in range(board.size()):
		for col in range(board.size()):
			if infected[row][col]:
				infected_count += 1
	
	for alien_data in available_aliens:
		available_count += alien_data.count
	
	if infected_count == total_cells:
		show_info_callback.call("Victory! Todo el tablero está infectado")
	elif available_count == 0 and infected_count < total_cells:
		show_info_callback.call("DERROTA: Sin aliens disponibles y tablero no completamente infectado")

static func validate_level(board: Array, aliens: Array, board_size: int, show_info_callback: Callable) -> bool:
	# Validate that the level has aliens and interesting terrain
	var has_aliens = false
	var terrain_variety = {}
	
	for row in range(board_size):
		for col in range(board_size):
			if aliens[row][col] != "":
				has_aliens = true
			
			var terrain = board[row][col]
			terrain_variety[terrain] = terrain_variety.get(terrain, 0) + 1
	
	if not has_aliens:
		show_info_callback.call("Warning: El nivel no tiene aliens colocados")
		return false
	
	if terrain_variety.size() < 3:
		show_info_callback.call("Warning: El nivel necesita más variedad de terrenos")
		return false
	
	return true

static func apply_terrain_rules_animated(board: Array, _board_size: int, auto_apply_rules: bool, show_info_callback: Callable, render_callback: Callable, tree: SceneTree):
	if not auto_apply_rules:
		return
	
	# Use the centralized terrain rules with ARIDO propagation enabled (turn resolution)
	# We'll create a simple wrapper that doesn't use problematic lambdas
	var animated_wrapper = AnimatedCallbackWrapper.new()
	animated_wrapper.setup(show_info_callback, render_callback, tree)
	
	var changes_made = GameLogic.apply_terrain_rules(board, auto_apply_rules, animated_wrapper.safe_callback, true)  # Allow ARIDO propagation
	
	if changes_made:
		render_callback.call()

# Safe callback wrapper class to avoid lambda capture issues
class AnimatedCallbackWrapper:
	var show_callback: Callable
	var render_callback: Callable
	var scene_tree: SceneTree
	
	func setup(show_cb: Callable, render_cb: Callable, tree: SceneTree):
		show_callback = show_cb
		render_callback = render_cb
		scene_tree = tree
	
	func safe_callback(msg: String):
		show_callback.call(msg)
		render_callback.call()
		if scene_tree and scene_tree.current_scene:
			await scene_tree.create_timer(0.1).timeout
