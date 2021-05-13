extends Node

# Built largely by following the doc: https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html#global-gd
var current_scene = null
var in_game_menu = null
var main_menu_scene = load("res://UI/Menu/MainMenu.tscn")
var packed_ships = load("res://Ships/PackedShips.tscn")
var ship_hangar = []
var packed_weapons = load("res://Weapons/PackedWeapons.tscn")
var weapon_hangar = []
var menu_open = false
var game_live = false
var hold_fire = false setget set_hold_fire
var debug_mode = false
var player_position := Vector2.ZERO
var home_beacon_position := Vector2.ZERO
export var day = true

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	_populate_hangars()
	
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

func set_hold_fire(hold_release: bool):
	hold_fire = hold_release

func debug_print(text):
	if debug_mode:
		print_debug(text)
		
func pause_game(pause: bool):
	get_tree().paused = pause

func _deferred_goto_scene(path):
	
	current_scene.free()
	
	#print("Loading level...", path)
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

func _populate_hangars():
	# In this function we're iterating through the Packed Weapon and Ship scenes, and organizing 
	# the ships and weapons into 2 2D Arrays that breakdown as follows:
	#	ship_hangar[Ship Class][Ship Index] .. i.e. references can be made like Global.ship_hangar[Frigate][2]
	#	weapon_hangar[Weapon SizeClass][Weapon Index] i.e. references can be made like  Global.weapon_hangar[Medium][3]
	var ships = packed_ships.instance()
	var weapons = packed_weapons.instance()
	var CIdx = 0	
	for Class in ships.get_children():
		#print("Class: ", Class)
		ship_hangar.append([])
		CIdx = Class.get_index()
		for Ship in Class.get_children():		
			if Ship.get_child_count() > 0:		
				if Ship.get_child(0):
					ship_hangar[CIdx].append([Ship.get_child(0)])
					#print("Ship ", ship_hangar[CIdx][Idx], " added to index [", CIdx, "][", Idx,"]")
	for Class in weapons.get_children():
		#print("Class: ", Class)
		weapon_hangar.append([])
		CIdx = Class.get_index()
		for Weapon in Class.get_children():
			if Weapon.get_child_count() > 0:
				if Weapon.get_child(0):
					weapon_hangar[CIdx].append([Weapon.get_child(0)])
					#print("Weapon ", weapon_hangar[CIdx][Idx], " added to index [", CIdx, "][", Idx, "]")
		
