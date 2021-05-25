extends RigidBody2D
signal removed

onready var sprite: Sprite = $Sprite
onready var mineral_dust: Particles2D = $MineralDust
var item_uuid

var despawn_timer
var particle_color: Color

func _ready() -> void:
	despawn_timer = Timer.new()
	add_child(despawn_timer)
	despawn_timer.wait_time = 12
	despawn_timer.connect("timeout", self, "_release_item")
	load_item_from_db()
	_generate_particles()
	_set_particle_color()

func pickup() -> void:
	PlayerVars.pickup_item(item_uuid)
	sprite.visible = false
	emit_signal("removed", self)
	mineral_dust.set_emitting(false)
	despawn_timer.start()
	

func load_item_from_db() -> void:
	var _items = Database.table.Items	
	var item_data = _items[randi() % _items.size()]
	var img = Image.new()
	item_uuid = item_data.itemUuid
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

func _release_item() -> void:
	call_deferred("queue_free")
