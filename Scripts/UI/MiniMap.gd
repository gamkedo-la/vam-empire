extends MarginContainer

# Largely adapted from an approach taken by https://kidscancode.org/godot_recipes/ui/minimap/

onready var pixel_grid = $ScreenContainer/PixelGrid
export var zoom = 10 setget set_zoom

onready var player_marker = $ScreenContainer/PixelGrid/PlayerMarker
var grid_scale 
var map_icons = {}

onready var zoomlbl = $Border/Zoom
onready var zoomtimer = $Border/Zoom/ZoomTimer

var _initialized = false

# Note: 192x108 (mini_map dimensions) is 1/5th of 960x540
func _ready():
	var _connect = UserSettings.connect("ui_refresh", self, "_refresh_settings")
	_refresh_settings()
	_connect = zoomtimer.connect("timeout", self, "_hide_zoom_lbl")	
	_connect = PlayerVars.connect("mission_complete", self, "_mission_complete")
	
	if not Global.is_connected("update_minimap", self, "_update_objs"):
		assert(Global.connect("update_minimap", self, "_update_objs") == OK)

func _initialize():
	player_marker.position = pixel_grid.rect_size/2
	player_marker.scale /= 5
	grid_scale = pixel_grid.rect_size / (get_viewport_rect().size * zoom)
	#print(get_viewport_rect().size)
	#print("player_marker: ", player_marker, " PlayerVars.player_node.position: ", PlayerVars.player_node.position)
	_update_objs()
	_initialized = true
	UserSettings.refresh_ui()
	_refresh_settings()

func _update_objs() -> void:
	var map_objects = get_tree().get_nodes_in_group("mini_map")
	#print("map_objects: ", map_objects.size())
	for obj in map_objects:
		if not obj.is_connected("removed", self, "_on_object_removed"):
			obj.connect("removed", self, "_on_object_removed")
			var new_icon = obj.get_node_or_null("Sprite").duplicate()
			if new_icon:
				new_icon.scale /= zoom
				pixel_grid.add_child(new_icon)
				new_icon.set_visible(true)
				map_icons[obj] = new_icon

func _process(_delta):
	if Input.is_action_pressed("minimap_zoom_in"):
		self.zoom -= 0.1		
		
	if Input.is_action_pressed("minimap_zoom_out"):		
		self.zoom += 0.1
		
		#print_debug("zoom", zoom)
	if !_initialized && PlayerVars.player_node:
		_initialize()
	if !PlayerVars.player_node:
		_initialized = false
		return	
	player_marker.rotation = PlayerVars.player_node.rotation
	var trash_pile = []
	for item in map_icons:
		if is_instance_valid(item):
			var obj_pos = (item.global_position - PlayerVars.player_node.global_position) * grid_scale + pixel_grid.rect_size / 2
			if !item.is_in_group("always_on_map"):
				if pixel_grid.get_rect().has_point(obj_pos + pixel_grid.rect_position):
					map_icons[item].set_visible(true)
				else:
					map_icons[item].set_visible(false)
			
			obj_pos.x = clamp(obj_pos.x, 0, pixel_grid.rect_size.x)
			obj_pos.y = clamp(obj_pos.y, 0, pixel_grid.rect_size.y)
			map_icons[item].position = obj_pos
			if !item.is_in_group("no_rotation_mini_map"):
				map_icons[item].global_rotation = item.global_rotation	
		else:
			trash_pile.append(item)
		
		if trash_pile.size() > 0:
			for trash in trash_pile:
				_on_object_removed(trash)
				print_debug("I just removed an item from the minimap")
		
	#player_marker.rotation = PlayerVars.player_node.rotation	

func set_zoom(value):
	zoomtimer.stop()
	zoom = clamp(value,0.5, 16)
	zoomlbl.text = str(zoom).pad_decimals(1)
	zoomlbl.visible = true
	grid_scale = pixel_grid.rect_size / (get_viewport_rect().size * zoom)
	zoomtimer.wait_time = 3
	zoomtimer.start()
	

func _hide_zoom_lbl():
	zoomlbl.visible = false

func _on_object_removed(icon):
	if icon in map_icons:
		map_icons[icon].queue_free()
		map_icons.erase(icon)

func _draw():
	pass


func _refresh_settings():	
	if UserSettings.mini_map_textures:
		#print_debug(UserSettings.mini_map_textures)
		pixel_grid.texture = UserSettings.mini_map_textures[UserSettings.current.ui.mini_map_style]	
	pixel_grid.self_modulate.a = UserSettings.current.ui.mini_map_grid_opacity
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MiniMap_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			self.zoom += 0.5
		if event.button_index == BUTTON_WHEEL_DOWN:
			self.zoom -= 0.5
			
func _mission_complete() -> void:
	self.visible = false
