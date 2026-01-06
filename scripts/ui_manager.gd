extends RefCounted
class_name UIManager

# UI styling and management functions

static func setup_ui_style(root_node: Control):
	# Style the main background
	var gradient = Gradient.new()
	gradient.colors = [Color(0.0588, 0.0588, 0.137), Color(0.102, 0.102, 0.18)]
	gradient.offsets = [0.0, 1.0]
	
	# Style title
	var title = root_node.get_node("Title")
	title.add_theme_color_override("font_color", Color(0, 1, 0.533))
	title.add_theme_font_size_override("font_size", 24)
	
	# Style panels to match HTML
	style_panel(root_node.get_node("GameContainer/BoardContainer"), Color(0.086, 0.129, 0.243), Color(0.059, 0.204, 0.376))
	style_panel(root_node.get_node("GameContainer/AlienList"), Color(0.086, 0.129, 0.243), Color(0.059, 0.204, 0.376))
	style_panel(root_node.get_node("Console"), Color(0.086, 0.129, 0.243), Color(0.059, 0.204, 0.376))

static func style_panel(panel: Panel, bg_color: Color, border_color: Color):
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = bg_color
	stylebox.border_width_left = 2
	stylebox.border_width_right = 2
	stylebox.border_width_top = 2
	stylebox.border_width_bottom = 2
	stylebox.border_color = border_color
	stylebox.corner_radius_top_left = 10
	stylebox.corner_radius_top_right = 10
	stylebox.corner_radius_bottom_left = 10
	stylebox.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", stylebox)

static func create_styled_button(text: String, size: Vector2 = Vector2(0, 32)) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	
	# Style the button to match HTML
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.102, 0.102, 0.18)
	stylebox.border_width_left = 1
	stylebox.border_width_right = 1
	stylebox.border_width_top = 1
	stylebox.border_width_bottom = 1
	stylebox.border_color = Color(0.059, 0.204, 0.376)
	stylebox.corner_radius_top_left = 3
	stylebox.corner_radius_top_right = 3
	stylebox.corner_radius_bottom_left = 3
	stylebox.corner_radius_bottom_right = 3
	button.add_theme_stylebox_override("normal", stylebox)
	
	return button

static func update_button_selection(buttons: Array, selected_index: int):
	for i in range(buttons.size()):
		var button = buttons[i] as Button
		if i == selected_index:
			button.modulate = Color(0.059, 1, 0.533)  # Green highlight
		else:
			button.modulate = Color.WHITE

static func update_mode_ui(mode: String, editor_controls: Control, alien_game_list: Control, editor_palette: Control, stats_container: Control):
	# Show/hide appropriate UI elements based on mode
	editor_controls.visible = (mode == "editor")
	alien_game_list.visible = (mode == "play")
	editor_palette.visible = (mode == "editor")
	stats_container.visible = (mode == "play")

static func update_stats_display(mode: String, infected_count: int, total_cells: int, available_count: int, chain_reactions: int, stats_container: Control):
	if mode != "play":
		return
	
	# Update stats labels
	stats_container.get_node("Level").text = "Nivel: %d" % 1
	stats_container.get_node("Infected").text = "Infectadas: %d/%d" % [infected_count, total_cells]
	stats_container.get_node("Available").text = "Aliens Restantes: %d" % available_count
	stats_container.get_node("Reactions").text = "Reacciones: %d" % chain_reactions
