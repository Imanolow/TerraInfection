extends RefCounted
class_name InteractionsManager

# Interactions panel and rules display

static func create_interactions_window(tree: SceneTree) -> Window:
	# Create interactions window
	var interactions_window = Window.new()
	interactions_window.title = "Tabla de Interacciones"
	interactions_window.size = Vector2i(800, 600)
	interactions_window.position = Vector2i(100, 100)
	
	# Create scroll container
	var scroll = ScrollContainer.new()
	scroll.anchors_preset = Control.PRESET_FULL_RECT
	interactions_window.add_child(scroll)
	
	# Create main container
	var main_container = VBoxContainer.new()
	scroll.add_child(main_container)
	
	# Add title
	var title = Label.new()
	title.text = "INTERACCIONES Y REGLAS"
	title.add_theme_font_size_override("font_size", 18)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(title)
	
	# Add terrain rules section
	var terrain_section = create_interactions_section("REGLAS DE TERRENO", [
		"• Arido + Agua adyacente -> Pantano",
		"• Hierba + 3+ Agua adyacente -> Pantano", 
		"• Bosque + Lava adyacente -> Arido",
		"• Granja + Infectada adyacente -> Infectada",
		"• Lava mata a la mayoria de aliens",
		"• Terreno Anulado mata a todos los aliens"
	])
	main_container.add_child(terrain_section)
	
	# Add alien effects section
	var alien_section = create_interactions_section("EFECTOS DE MUERTE DE ALIENS", [
		"Devastador: Area 3x3 -> Arido",
		"Hidrofobico: Terreno -> Anulado", 
		"Toxico: Area 3x3 -> Arido + mata granjas 5x5",
		"Explosivo: Area 5x5 -> Arido",
		"Piroclasta: Area 3x3 -> Lava"
	])
	main_container.add_child(alien_section)
	
	# Add transformation section
	var transform_section = create_interactions_section("TRANSFORMACIONES DE ALIENS", [
		"Infectador: Granja -> Infectada",
		"Petrificador: Agua -> Roca",
		"Regenerador: Arido -> Hierba", 
		"Congelador: Agua -> Hielo",
		"Purificador: Infectada -> Granja"
	])
	main_container.add_child(transform_section)
	
	# Add specialist section
	var specialist_section = create_interactions_section("ALIENS ESPECIALISTAS", [
		"Minero: Extrae cristales",
		"Anfibio: Inmune al agua",
		"Simbiotico: Coopera con bosques",
		"Fantasma: Atraviesa terrenos"
	])
	main_container.add_child(specialist_section)
	
	# Add strategic section
	var strategic_section = create_interactions_section("ALIENS ESTRATEGICOS", [
		"Colonia: Coordina otros aliens",
		"Barrera: Protege zona",
		"Catalizador: Acelera reacciones"
	])
	main_container.add_child(strategic_section)
	
	# Show window
	tree.root.add_child(interactions_window)
	interactions_window.show()
	
	return interactions_window

static func create_interactions_section(title: String, rules: Array) -> VBoxContainer:
	var section = VBoxContainer.new()
	
	# Section title
	var section_title = Label.new()
	section_title.text = title
	section_title.add_theme_font_size_override("font_size", 14)
	section_title.add_theme_color_override("font_color", Color(0.059, 1, 0.533))
	section.add_child(section_title)
	
	# Rules
	for rule in rules:
		var rule_label = Label.new()
		rule_label.text = rule
		rule_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		section.add_child(rule_label)
	
	# Separator
	var separator = HSeparator.new()
	separator.custom_minimum_size.y = 10
	section.add_child(separator)
	
	return section
