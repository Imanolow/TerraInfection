# Main Menu for Terra Infecta Level Editor
extends Control

# UI References
@onready var continue_btn = $VBoxContainer/ContinueBtn
@onready var new_game_btn = $VBoxContainer/NewGameBtn
@onready var editor_btn = $VBoxContainer/EditorBtn
@onready var options_btn = $VBoxContainer/OptionsBtn
@onready var exit_btn = $VBoxContainer/ExitBtn
@onready var title_label = $VBoxContainer/TitleLabel

func _ready():
	# Set up the UI styling
	setup_ui_style()
	
	# Connect button signals
	connect_signals()
	
	# Set up initial button states
	setup_initial_state()

func setup_ui_style():
	# Set up the main container styling
	var bg_color = Color(0.1, 0.1, 0.15, 1.0)  # Dark blue-gray background
	var border_color = Color(0.3, 0.3, 0.4, 1.0)
	
	# Style the main panel
	if has_method("add_theme_stylebox_override"):
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = bg_color
		panel_style.border_color = border_color
		panel_style.border_width_top = 2
		panel_style.border_width_bottom = 2
		panel_style.border_width_left = 2
		panel_style.border_width_right = 2
		add_theme_stylebox_override("panel", panel_style)
	
	# Style the title
	title_label.text = "TERRA INFECTION"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Style buttons
	style_menu_button(continue_btn, "Continuar", false)  # Disabled for now
	style_menu_button(new_game_btn, "Nuevo Juego", false)  # Disabled for now
	style_menu_button(editor_btn, "Editor", true)
	style_menu_button(options_btn, "Opciones", false)  # Disabled for now
	style_menu_button(exit_btn, "Salir", true)

func style_menu_button(button: Button, text: String, enabled: bool):
	button.text = text
	button.disabled = not enabled
	
	# Create button style
	var button_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var disabled_style = StyleBoxFlat.new()
	
	if enabled:
		# Normal state
		button_style.bg_color = Color(0.2, 0.3, 0.4, 1.0)
		button_style.border_color = Color(0.4, 0.5, 0.6, 1.0)
		
		# Hover state
		hover_style.bg_color = Color(0.3, 0.4, 0.5, 1.0)
		hover_style.border_color = Color(0.5, 0.6, 0.7, 1.0)
		
		# Pressed state
		pressed_style.bg_color = Color(0.1, 0.2, 0.3, 1.0)
		pressed_style.border_color = Color(0.3, 0.4, 0.5, 1.0)
	else:
		# Disabled state
		disabled_style.bg_color = Color(0.15, 0.15, 0.2, 1.0)
		disabled_style.border_color = Color(0.25, 0.25, 0.3, 1.0)
	
	# Apply border settings to all styles
	for style in [button_style, hover_style, pressed_style, disabled_style]:
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_width_left = 2
		style.border_width_right = 2
		style.corner_radius_top_left = 5
		style.corner_radius_top_right = 5
		style.corner_radius_bottom_left = 5
		style.corner_radius_bottom_right = 5
	
	# Apply styles to button
	button.add_theme_stylebox_override("normal", button_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)
	
	# Set button size
	button.custom_minimum_size = Vector2(200, 50)

func connect_signals():
	# Connect button signals
	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	editor_btn.pressed.connect(_on_editor_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

func setup_initial_state():
	# Focus on the editor button since it's the main functionality for now
	editor_btn.grab_focus()

func _on_continue_pressed():
	# TODO: Load last saved game/level
	print("Continue pressed - Not implemented yet")

func _on_new_game_pressed():
	# TODO: Start new campaign/game
	print("New Game pressed - Not implemented yet")

func _on_editor_pressed():
	# Switch to the level editor scene
	get_tree().change_scene_to_file("res://scenes/isometric_board.tscn")

func _on_options_pressed():
	# TODO: Open options menu (resolution, audio, etc.)
	print("Options pressed - Not implemented yet")

func _on_exit_pressed():
	# Exit the game
	get_tree().quit()

func _input(event):
	# Allow ESC to exit the game from main menu
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
