extends CanvasLayer

@onready var board = get_parent()

func _ready():
	# Create UI container
	var panel = PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.15
	panel.anchor_bottom = 0.35
	panel.offset_left = 10
	panel.offset_top = 10
	panel.offset_right = -10
	panel.offset_bottom = -10
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "Board Size:"
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	# Buttons for each size
	var sizes = [4, 5, 6, 7, 8]
	for size in sizes:
		var button = Button.new()
		button.text = "%dx%d" % [size, size]
		button.pressed.connect(_on_size_button_pressed.bind(size))
		vbox.add_child(button)

func _on_size_button_pressed(size: int) -> void:
	board.set_board_size(size)
