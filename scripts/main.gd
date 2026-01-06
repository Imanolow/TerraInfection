extends Control

# External data sources
var terrain_data = preload("res://scripts/terrains.gd").new()
var alien_data = preload("res://scripts/aliens.gd").new()

# Data access (maintaining exact same access pattern)
var TERRAINS: Dictionary
var ALIENS: Dictionary

# Game State
var board_size: int = 6
var mode: String = "editor"  # "editor" or "play"
var test_mode: bool = false
var auto_apply_rules: bool = true

# Board data
var board: Array = []
var aliens: Array = []
var infected: Array = []

# Selected items
var selected_terrain: String = ""
var selected_alien: String = ""
var selected_alien_index: int = -1

# Game stats
var turn: int = 0
var chain_reactions: int = 0
var available_aliens: Array = []

# Processing state
var processing_turn: bool = false

# Safe callback functions to prevent lambda capture errors
func _safe_console_callback(msg: String):
	if is_inside_tree() and console_content:
		show_console_info(msg)

func _safe_kill_callback(r: int, c: int):
	if is_inside_tree():
		kill_aliens_in_cell(r, c)

func _safe_render_callback():
	if is_inside_tree():
		render_board()

# UI References
@onready var board_area = $GameContainer/BoardContainer/BoardArea
@onready var terrain_palette = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorPalette/TerrainSection/TerrainPalette
@onready var alien_palette = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorPalette/AlienSection/AlienPalette
@onready var console_content = $Console/ScrollContainer/ConsoleContent
@onready var stats_container = $GameContainer/BoardContainer/Stats
@onready var editor_controls = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls
@onready var alien_game_list = $GameContainer/AlienList/ScrollContainer/VBoxContainer/AlienGameList
@onready var editor_palette = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorPalette

# Size selector buttons
@onready var size_buttons = [
	$GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/SizeSection/SizeSelector/Size4x4,
	$GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/SizeSection/SizeSelector/Size5x5,
	$GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/SizeSection/SizeSelector/Size6x6,
	$GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/SizeSection/SizeSelector/Size7x7,
	$GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/SizeSection/SizeSelector/Size8x8
]

# Control buttons
@onready var mode_btn = $GameContainer/BoardContainer/Controls/ModeBtn
@onready var new_game_btn = $GameContainer/BoardContainer/Controls/NewGameBtn
@onready var reset_btn = $GameContainer/BoardContainer/Controls/ResetBtn
@onready var main_menu_btn = $GameContainer/BoardContainer/Controls/MainMenuBtn
@onready var clear_btn = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/Controls1/ClearBtn
@onready var test_btn = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/Controls1/TestBtn
@onready var interactions_btn = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/Controls1/InteractionsBtn
@onready var save_btn = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/Controls2/SaveBtn
@onready var load_btn = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/Controls2/LoadBtn
@onready var list_btn = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/Controls2/ListLevelsBtn
@onready var auto_apply_toggle = $GameContainer/AlienList/ScrollContainer/VBoxContainer/EditorControls/SettingsSection/AutoApplyToggle

func _ready():
	# Initialize data dictionaries from external scripts
	TERRAINS = terrain_data.TERRAINS
	ALIENS = alien_data.ALIENS
	
	# Set up the UI styling to match HTML
	setup_ui_style()
	
	# Connect button signals
	connect_signals()
	
	# Initialize game
	init_game()
	
	# Set up terrain and alien palettes
	setup_palettes()
	
	# Wait for UI to be ready then render board
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Clear console to show only title
	clear_console()
	
	# Render initial state
	render_board()
	update_mode_ui()

func setup_ui_style():
	UIManager.setup_ui_style(self)

func style_panel(panel: Panel, bg_color: Color, border_color: Color):
	UIManager.style_panel(panel, bg_color, border_color)

func connect_signals():
	# Size buttons
	for i in range(size_buttons.size()):
		size_buttons[i].pressed.connect(set_board_size.bind(i + 4))
	
	# Control buttons
	mode_btn.pressed.connect(toggle_mode)
	new_game_btn.pressed.connect(new_game)
	reset_btn.pressed.connect(reset_level)
	main_menu_btn.pressed.connect(goto_main_menu)
	clear_btn.pressed.connect(clear_board)
	test_btn.pressed.connect(test_level)
	interactions_btn.pressed.connect(toggle_interactions)
	save_btn.pressed.connect(save_level)
	load_btn.pressed.connect(load_level)
	list_btn.pressed.connect(list_levels)
	auto_apply_toggle.toggled.connect(toggle_auto_apply)

func init_game():
	# Initialize board arrays
	board = []
	aliens = []
	infected = []
	
	for row in range(board_size):
		board.append([])
		aliens.append([])
		infected.append([])
		for col in range(board_size):
			board[row].append("HIERBA")
			aliens[row].append("")
			infected[row].append(false)
	
	# Reset game state
	turn = 0
	chain_reactions = 0
	selected_terrain = ""
	selected_alien = ""
	selected_alien_index = -1
	
	# Set up available aliens for play mode
	if mode == "play" or test_mode:
		available_aliens = GameModeManager.setup_play_mode_aliens()

func set_board_size(new_size: int):
	board_size = new_size
	
	# Update size button states
	for i in range(size_buttons.size()):
		size_buttons[i].button_pressed = (i + 4 == new_size)
	
	# Reinitialize with new size
	init_game()
	render_board()

func setup_palettes():
	# Clear existing palette items
	for child in terrain_palette.get_children():
		child.queue_free()
	for child in alien_palette.get_children():
		child.queue_free()
	
	# Create terrain palette
	for terrain_key in TERRAINS:
		var terrain = TERRAINS[terrain_key]
		var button = UIManager.create_styled_button(terrain.name)
		button.pressed.connect(select_terrain.bind(terrain_key))
		terrain_palette.add_child(button)
	
	# Create alien palette
	for alien_key in ALIENS:
		var alien = ALIENS[alien_key]
		var button = UIManager.create_styled_button(alien.name)
		button.pressed.connect(select_alien.bind(alien_key))
		alien_palette.add_child(button)

func select_terrain(terrain_key: String):
	selected_terrain = terrain_key
	selected_alien = ""
	update_palette_selection()
	
	# Show complete terrain information (name, description, category)
	var terrain = TERRAINS[terrain_key]
	clear_console()
	show_console_info(ConsoleManager.format_terrain_info(terrain))

func select_alien(alien_key: String):
	selected_alien = alien_key
	selected_terrain = ""
	update_palette_selection()
	
	# Show complete alien information (name, class, description, characteristics)
	var alien = ALIENS[alien_key]
	clear_console()
	show_console_info(ConsoleManager.format_alien_info(alien))

func update_palette_selection():
	# Update terrain palette visual selection
	var terrain_children = terrain_palette.get_children()
	var terrain_keys = TERRAINS.keys()
	var selected_terrain_index = -1
	for i in range(terrain_keys.size()):
		if terrain_keys[i] == selected_terrain:
			selected_terrain_index = i
			break
	UIManager.update_button_selection(terrain_children, selected_terrain_index)
	
	# Update alien palette visual selection
	var alien_children = alien_palette.get_children()
	var alien_keys = ALIENS.keys()
	var alien_selection_index = -1
	for i in range(alien_keys.size()):
		if alien_keys[i] == selected_alien:
			alien_selection_index = i
			break
	UIManager.update_button_selection(alien_children, alien_selection_index)

func render_board():
	BoardRenderer.render_board_complete(board, aliens, infected, board_area, TERRAINS, ALIENS, board_size, _on_cell_clicked_simple, _on_cell_hover_iso)

func _on_cell_clicked_simple(row: int, col: int):
	select_cell(row, col)

func _on_cell_hover_iso(row: int, col: int, hovering: bool, polygon: Polygon2D):
	BoardRenderer.handle_cell_hover_iso(row, col, hovering, polygon, board_area)

func select_cell(row: int, col: int):
	# First, show detailed cell information (replacing previous content)
	var terrain = TERRAINS[board[row][col]]
	var alien_info = {}
	if aliens[row][col] != "":
		alien_info = ALIENS[aliens[row][col]]
	
	var info = ConsoleManager.format_cell_info(terrain, alien_info)
	clear_console()
	show_console_info(info)
	
	if mode == "editor":
		# Editor mode - place terrain or alien
		if selected_terrain != "":
			board[row][col] = selected_terrain
			apply_terrain_rules()
			render_board()
		elif selected_alien != "":
			aliens[row][col] = selected_alien
			infected[row][col] = true  # Aliens automatically infect their cell
			# Apply alien transformations immediately in editor mode (like HTML original)
			apply_alien_transformations()
			apply_terrain_rules()  # Apply terrain rules after alien transformations
			render_board()
	else:
		# Play mode - place selected alien
		if selected_alien_index >= 0 and available_aliens[selected_alien_index].count > 0:
			if aliens[row][col] == "":  # Only place if cell is empty
				var alien_type = available_aliens[selected_alien_index].type
				aliens[row][col] = alien_type
				infected[row][col] = true
				available_aliens[selected_alien_index].count -= 1
				
				# Process turn after placing alien
				process_turn()
				render_alien_list()  # Update alien list with new counts

func apply_terrain_rules():
	# Use GameLogic for terrain rules with safe wrapper
	GameLogic.apply_terrain_rules(board, auto_apply_rules, _safe_console_callback, false)  # No ARIDO propagation in editor

func get_neighbors(row: int, col: int) -> Array:
	return GameLogic.get_neighbors(row, col, board_size)

func get_area_cells(row: int, col: int, area_size: int) -> Array:
	return GameLogic.get_area_cells(row, col, area_size, board_size)

func apply_alien_death_effects(row: int, col: int, alien_type: String):
	chain_reactions += GameLogic.apply_alien_death_effects(row, col, alien_type, board, ALIENS, _safe_console_callback, _safe_kill_callback)

func kill_aliens_in_cell(row: int, col: int):
	if aliens[row][col] != "":
		var alien_type = aliens[row][col]
		aliens[row][col] = ""
		infected[row][col] = false
		# Chain reaction - apply death effects
		apply_alien_death_effects(row, col, alien_type)

func apply_alien_transformations():
	GameLogic.apply_alien_transformations(board, aliens, _safe_console_callback)

func check_alien_survival():
	GameLogic.check_alien_survival(board, aliens, infected, ALIENS, _safe_console_callback, _safe_kill_callback)

func process_turn():
	if mode != "play" or processing_turn:
		return
	
	processing_turn = true
	turn += 1
	show_console_info("Turn: Turno %d iniciado" % turn)
	
	# Apply alien transformations first
	apply_alien_transformations()
	
	# Apply terrain rules with animation delay
	if auto_apply_rules:
		await apply_terrain_rules_animated()
	
	# Check alien survival
	check_alien_survival()
	
	# Update visuals
	render_board()
	update_stats()
	
	# Check win/lose conditions
	check_game_state()
	
	processing_turn = false
	show_console_info("Check: Turno %d completado" % turn)

func apply_terrain_rules_animated():
	await GameModeManager.apply_terrain_rules_animated(board, board_size, auto_apply_rules, _safe_console_callback, _safe_render_callback, get_tree())

func check_game_state():
	GameModeManager.check_game_state(board, infected, available_aliens, _safe_console_callback)

func toggle_mode():
	if mode == "editor":
		mode = "play"
		test_mode = false
		mode_btn.text = "Modo Juego"
		new_game_btn.visible = true
	else:
		mode = "editor"
		test_mode = false
		mode_btn.text = "Modo Editor"
		new_game_btn.visible = false
	
	update_mode_ui()
	show_console_info("Cambiado a modo: " + mode)

func test_level():
	# Validate level using GameModeManager
	if not GameModeManager.validate_level(board, aliens, board_size, _safe_console_callback):
		return
	
	# Switch to test/play mode temporarily
	mode = "play"
	test_mode = true
	
	# Set up test environment
	turn = 0
	chain_reactions = 0
	available_aliens = GameModeManager.setup_test_mode_aliens()
	
	update_mode_ui()
	show_console_info("Test: Modo de prueba activado - ¡Prueba tu nivel!")
	show_console_info("Idea: Usa el botón Reset para volver al editor")

func new_game():
	init_game()
	render_board()
	update_stats()
	show_console_info("New: Nuevo juego iniciado")

func reset_level():
	if test_mode:
		# Return to editor mode
		mode = "editor"
		test_mode = false
		show_console_info("Return: Regresando al modo editor")
	else:
		# Reset current mode
		show_console_info("Reset: Nivel reiniciado")
	
	init_game()
	render_board()
	update_mode_ui()

func clear_board():
	for row in range(board_size):
		for col in range(board_size):
			board[row][col] = "HIERBA"
			aliens[row][col] = ""
			infected[row][col] = false
	render_board()
	show_console_info("Clean: Tablero limpiado")

# Interactions window
var interactions_window: Window = null

func toggle_interactions():
	if interactions_window and is_instance_valid(interactions_window):
		interactions_window.queue_free()
		interactions_window = null
		show_console_info("Table: Tabla de interacciones cerrada")
	else:
		show_interactions_panel()

func show_interactions_panel():
	interactions_window = InteractionsManager.create_interactions_window(get_tree())
	show_console_info("Table: Tabla de interacciones mostrada")

func create_interactions_section(title: String, rules: Array) -> VBoxContainer:
	return InteractionsManager.create_interactions_section(title, rules)

func toggle_auto_apply(enabled: bool):
	auto_apply_rules = enabled
	if enabled:
		show_console_info("Settings: Auto-aplicar reglas activado")
	else:
		show_console_info("Settings: Auto-aplicar reglas desactivado")

func save_level():
	var result = SaveSystem.save_level(board, aliens, infected, board_size)
	if result != "":
		show_console_info("Save: Nivel guardado como: " + result)
	else:
		show_console_info("Error: Error al guardar el nivel")

func load_level():
	var result = SaveSystem.load_level()
	if result.success:
		# Load the data
		board_size = result.board_size
		board = result.board
		aliens = result.aliens
		infected = result.infected
		
		# Update size buttons
		for i in range(size_buttons.size()):
			size_buttons[i].button_pressed = (i + 4 == board_size)
		
		# Re-render
		render_board()
		show_console_info("Load: Nivel cargado: " + result.filename)
	else:
		show_console_info("Error: " + result.error)

func list_levels():
	# Function disabled to avoid cluttering console
	show_console_info("List: Función de listado de niveles deshabilitada para mantener la consola limpia")
	return

func update_mode_ui():
	# Show/hide appropriate UI elements based on mode
	editor_controls.visible = (mode == "editor")
	alien_game_list.visible = (mode == "play")
	editor_palette.visible = (mode == "editor")
	stats_container.visible = (mode == "play")
	
	if mode == "play":
		render_alien_list()

func render_alien_list():
	GameModeManager.render_alien_list(alien_game_list, available_aliens, ALIENS, select_alien_for_play)

func select_alien_for_play(index: int):
	selected_alien_index = index
	
	# Update visual selection using GameModeManager
	GameModeManager.update_alien_selection_visual(alien_game_list, index)
	
	var alien_available = available_aliens[index]
	var alien_info = ALIENS[alien_available.type]
	show_console_info("Ship: %s Seleccionado\n%s\nDisponibles: %d" % [alien_info.name, alien_info.description, alien_available.count])

func update_stats():
	if mode != "play":
		return
	
	GameModeManager.update_stats_display(stats_container, board, infected, available_aliens, turn, chain_reactions)

func clear_console():
	ConsoleManager.clear_console(console_content)

func show_console_info(message: String):
	ConsoleManager.show_console_info(console_content, message)

func goto_main_menu():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event):
	# Allow ESC to return to main menu from editor
	if event.is_action_pressed("ui_cancel"):
		goto_main_menu()
