# Scene Manager for Terra Infecta
# Handles scene transitions and global game state
extends Node

# Scene paths
const MAIN_MENU_SCENE = "res://scenes/main_menu.tscn"
const LEVEL_EDITOR_SCENE = "res://scenes/main.tscn"

# Current scene reference
var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String):
	# This function will switch to a scene
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	# Free the current scene
	current_scene.free()
	
	# Load the new scene
	var new_scene = ResourceLoader.load(path)
	
	# Instance the new scene
	current_scene = new_scene.instantiate()
	
	# Add it to the active scene, as child of root
	get_tree().root.add_child(current_scene)
	
	# Make it the current scene
	get_tree().current_scene = current_scene

func goto_main_menu():
	goto_scene(MAIN_MENU_SCENE)

func goto_level_editor():
	goto_scene(LEVEL_EDITOR_SCENE)

func quit_game():
	get_tree().quit()
