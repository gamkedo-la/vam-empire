extends RigidBody2D

#signal to alert minimap and any other connected objects on removal
signal removed

export var health = 200

export (float, 0.1, 10.0) var highlight_width_start = 1.0
export (float, 1.0, 20.0) var highlight_width_end = 2.0
export (float, 0.5, 5) var highlight_pulse_speed = 0.5

onready var sprite = $Sprite
onready var targ_tween = $HighlightTween
onready var hurt_box = $HurtBox
var coll_efx: AudioStreamPlayer2D
onready var mine_spawner = preload("res://Pickups/MineSpawner.tscn")
export (Array, String) var mineral_contents
var miners = {}

func _ready():
	add_to_group("mini_map")
	sprite.material.set_shader_param("textureName_size", sprite.texture.get_size())
	angular_velocity = rand_range(-8.0, 8.0)
	angular_damp = 0.0
	coll_efx = get_node_or_null("CollisionEfx")

func _process(_delta):
	if health < 0:
		_free_asteroid()
	


func _free_asteroid():
	emit_signal("removed", self)
	if PlayerVars.get_target() == self:
		PlayerVars.set_target(null)
	queue_free()

func _on_HurtBox_area_entered(area):	
	var hitParent = area.get_parent()
	print_debug(hitParent)
	if !hitParent.is_in_group("can_mine"):
		health -= hitParent.Damage		
		Effects.show_dmg_text(hitParent.global_position, hitParent.Damage)
		hitParent.hit_something()
	else:	
		var laser = area.get_parent()		
		var newMine = mine_spawner.instance()		
		newMine.mineral_uuid = mineral_contents[randi() % mineral_contents.size()]
		laser.connect("disengage", newMine, "_remove_mine_spawner")		
		get_tree().get_root().add_child(newMine)
		newMine.laser = laser
		newMine.global_position = self.global_position.linear_interpolate(area.global_position, .25)

func _on_MedAsteroid01_body_shape_entered(body_id, body, body_shape, local_shape):	
	print_debug(body)
	if body.is_in_group("player"):
		print_debug("Hit the player!")
		
	pass # Replace with function body.

func _on_Asteroid001_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func _on_Asteroid002_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func _on_Asteroid003_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func unset_target():
	targ_tween.stop_all()
	if sprite.material.get_shader_param("width") > 0.0:
		sprite.material.set_shader_param("width", 0.0)

func make_target(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		PlayerVars.set_target(self)
		sprite.material.set_shader_param("width", 1.0)
		targ_tween.interpolate_property(sprite.material,
									"shader_param/width",
									highlight_width_start, highlight_width_end, highlight_pulse_speed,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		
		targ_tween.interpolate_property(sprite.material,
									"shader_param/outline_color",
									sprite.material.get_shader_param("color_one"),sprite.material.get_shader_param("color_two"), highlight_pulse_speed*2,
									Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1)
		targ_tween.start()

func _on_HighlightTween_tween_completed(object, key):
#	print("object: ", object, "key: ", key)
	if key == ":shader_param/width":
		var cur_width = sprite.material.get_shader_param("width")
		var targ_width = highlight_width_end
		if cur_width > (highlight_width_start + .1):
			targ_width = highlight_width_start
		targ_tween.interpolate_property(sprite.material,
							"shader_param/width",
							cur_width, targ_width, highlight_pulse_speed,
							Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		targ_tween.start()
	if key == ":shader_param/outline_color":
		var cur_color = sprite.material.get_shader_param("outline_color")
		var targ_color = sprite.material.get_shader_param("color_two")
		if cur_color == targ_color:
			targ_color = sprite.material.get_shader_param("color_one")
		targ_tween.interpolate_property(sprite.material,
							"shader_param/outline_color",
							cur_color,targ_color, highlight_pulse_speed*2,
							Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		targ_tween.start()






