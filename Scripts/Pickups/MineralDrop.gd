extends Node2D

onready var sprite: Sprite = $Sprite
onready var mineral_dust: Particles2D = $MineralDust

var particle_color: Color

func _ready() -> void:
	
	load_image_from_db()
	_generate_particles()
	_set_particle_color()
	
func load_image_from_db() -> void:
	var _items = Database.table.Items	
	var item_data = _items[randi() % _items.size()]
	var img = Image.new()
	sprite.texture = load(item_data.itemIcon)
	img = sprite.texture.get_data()
	img.lock()
	particle_color = img.get_pixel(16,16)
	img.unlock()
#	print_debug("Color: ", particle_color, "Image: ", item_data.itemIcon)

func _generate_particles() -> void:
	var proc_mat = mineral_dust.process_material.duplicate(true)
	mineral_dust.process_material = proc_mat
	
func _set_particle_color() -> void:
	mineral_dust.process_material.color = particle_color
	pass


#	var items = Database.table.Items
#	return items[randi() % items.size()]
