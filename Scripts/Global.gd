extends Node

# Built largely by following the doc: https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html#global-gd
var current_scene = null
var in_game_menu = null
var main_menu_scene = load("res://UI/Menu/MainMenu.tscn")
var menu_open = false
var game_live = false
var hold_fire = false
export var day = true

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
func goto_scene(path):
	# Defer the load until the current scene is done executing code
	print("Getting to goto_scene...")
	call_deferred("_deferred_goto_scene", path)

# A function to simplify reparenting nodes, a function that will likely happen a lot as we design things "Modularly"
func reparent(child: Node, new_parent: Node):
	if child:
		var old_parent = child.get_parent()
		old_parent.remove_child(child)
		new_parent.add_child(child)
	else:
		print_debug("Global.gd: Attempt to reparent child node failed due to child being null.")

func hold_fire(hold_release: bool):
	hold_fire = hold_release

func _deferred_goto_scene(path):
	
	current_scene.free()
	
	print("Loading level...", path)
	var s = load(path)
	
	current_scene = s.instance()
	
	get_tree().get_root().add_child(current_scene)
	
	get_tree().set_current_scene(current_scene)
	
func _deferred_close_menu():
	in_game_menu.free()
	
func _display_menu():
	if !menu_open:
		get_tree().paused = true
		in_game_menu = main_menu_scene.instance()		
		get_tree().get_root().add_child(in_game_menu)		
		in_game_menu._disable_new()
		menu_open = true
	else:
		if in_game_menu:
			in_game_menu.visible = false
			call_deferred("_deferred_close_menu")
		if get_tree().paused == true:
			get_tree().paused = false
		menu_open = false
