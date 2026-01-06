extends CanvasLayer

@onready var board = get_parent()
var selected_terrain_button: Button = null

func _ready():
	# Wait one frame to ensure board is fully initialized
	await get_tree().process_frame
	
	# Create main container
	var main_container = HBoxContainer.new()
	main_container.anchor_left = 0.0
	main_container.anchor_top = 0.0
	main_container.anchor_right = 1.0
	main_container.anchor_bottom = 1.0
	add_child(main_container)
	
	# Left panel - Board size
	var left_panel = PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(150, 0)
	main_container.add_child(left_panel)
	
	var left_vbox = VBoxContainer.new()
	left_panel.add_child(left_vbox)
	
	var title1 = Label.new()
	title1.text = "Board Size:"
	title1.add_theme_font_size_override("font_size", 14)
	left_vbox.add_child(title1)
	
	var sizes = [4, 5, 6, 7, 8, 9]
	for size in sizes:
		var button = Button.new()
		button.text = "%dx%d" % [size, size]
		button.pressed.connect(_on_size_button_pressed.bind(size))
		left_vbox.add_child(button)
	
	# Right panel - Terrains
	var right_panel = PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(250, 0)
	main_container.add_child(right_panel)
	
	var right_vbox = VBoxContainer.new()
	right_panel.add_child(right_vbox)
	
	var title2 = Label.new()
	title2.text = "Terrenos:"
	title2.add_theme_font_size_override("font_size", 14)
	right_vbox.add_child(title2)
	
	# Scroll for terrains
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(250, 400)
	right_vbox.add_child(scroll)
	
	var terrain_vbox = VBoxContainer.new()
	scroll.add_child(terrain_vbox)
	
	# Create buttons for each terrain
	var terrains_dict = board.terrains
	for terrain_key in terrains_dict.keys():
		var button = Button.new()
		var terrain_data = terrains_dict[terrain_key]
		button.text = terrain_data["name"]
		button.pressed.connect(_on_terrain_button_pressed.bind(terrain_key, button))
		terrain_vbox.add_child(button)
		
		# Select HIERBA by default
		if terrain_key == "HIERBA":
			selected_terrain_button = button
			button.modulate = Color.YELLOW

func _on_size_button_pressed(size: int) -> void:
	board.set_board_size(size)

func _on_terrain_button_pressed(terrain_key: String, button: Button) -> void:
	# Deselect previous
	if selected_terrain_button != null:
		selected_terrain_button.modulate = Color.WHITE
	
	# Select new
	selected_terrain_button = button
	button.modulate = Color.YELLOW
	board.set_selected_terrain(terrain_key)
