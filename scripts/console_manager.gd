extends RefCounted
class_name ConsoleManager

# Console management and information display

static func clear_console(console_content: RichTextLabel):
	console_content.text = "[b]Consola[/b]"

static func show_console_info(console_content: RichTextLabel, message: String):
	# REPLACE content, don't accumulate (as requested)
	console_content.text = "[b]Consola[/b]\n\n" + message

static func show_console_info_with_scroll(console_content: RichTextLabel, message: String, tree: SceneTree):
	# REPLACE content, don't accumulate (as requested)
	console_content.text = "[b]Consola[/b]\n\n" + message
	
	# Auto-scroll to bottom
	await tree.process_frame
	var scroll = console_content.get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

static func format_terrain_info(terrain: Dictionary) -> String:
	return "%s\n\nDescripción: %s\n\nCategoría: %s" % [terrain.name, terrain.description, terrain.category]

static func format_alien_info(alien: Dictionary) -> String:
	var info = "%s\n\nClase: %s\n\nDescripción: %s" % [alien.name, alien.class, alien.description]
	
	# Add weakness or immunity if available
	if alien.has("weakness") and alien.weakness != "":
		info += "\n\n" + alien.weakness
	if alien.has("immunity") and alien.immunity != "":
		info += "\n\n" + alien.immunity
	
	return info

static func format_cell_info(terrain: Dictionary, alien: Dictionary = {}) -> String:
	var info = format_terrain_info(terrain)
	
	# If there's an alien, add its information
	if not alien.is_empty():
		info += "\n\n--- ALIEN ---\n\n" + format_alien_info(alien)
	
	return info
