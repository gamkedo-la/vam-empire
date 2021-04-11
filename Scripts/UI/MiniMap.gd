extends MarginContainer

# Largely adapted from an approach taken by https://kidscancode.org/godot_recipes/ui/minimap/

onready var pixel_grid = $MiniMapCanvas
export var zoom = 4.5

var player_marker = Vector2.ZERO
var grid_scale 
var map_icons = {}


var _initialized = false

# Note: 192x108 (mini_map dimensions) is 1/5th of 960x540
func _ready():
	pass

func _initialize():
	player_marker = Vector2.ONE * (pixel_grid.rect_size/2)
	grid_scale = pixel_grid.rect_size / (get_viewport_rect().size * zoom)
	print("player_marker: ", player_marker, " PlayerVars.player_node.position: ", PlayerVars.player_node.position)
	var map_objects = get_tree().get_nodes_in_group("mini_map")
	print("map_objects: ", map_objects.size())
	for obj in map_objects:		
		var new_icon = obj.get_node_or_null("Sprite").duplicate()
		if new_icon:
			new_icon.scale /= 10
			pixel_grid.add_child(new_icon)
			new_icon.set_visible(true)
			map_icons[obj] = new_icon
		
	_initialized = true

func _process(delta):
	if !_initialized && PlayerVars.player_node:
		_initialize()
	if !PlayerVars.player_node:
		_initialized = false
		return
	for item in map_icons:
		if item:
			var obj_pos = (item.position - PlayerVars.player_node.position) * grid_scale + pixel_grid.rect_size / 2
			obj_pos.x = clamp(obj_pos.x, 0, pixel_grid.rect_size.x)
			obj_pos.y = clamp(obj_pos.y, 0, pixel_grid.rect_size.y)
			map_icons[item].position = obj_pos
		else:
			map_icons.erase(item)
	
	
	#player_marker.rotation = PlayerVars.player_node.rotation	
	


func _draw():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
