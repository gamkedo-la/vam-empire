extends RigidBody2D

#signal to alert minimap and any other connected objects on removal
signal removed

export var health = 200

onready var sprite = $Sprite

func _ready():
	add_to_group("mini_map")
	sprite.material.set_shader_param("textureName_size", sprite.texture.get_size())
	angular_velocity = rand_range(-8.0, 8.0)
	angular_damp = 0.0

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
	health -= hitParent.Damage
	Effects.show_dmg_text(hitParent.global_position, hitParent.Damage)
	hitParent.hit_something()


func _on_Asteroid001_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func _on_Asteroid002_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func _on_Asteroid003_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func unset_target():
	if sprite.material.get_shader_param("width") > 0.0:
		sprite.material.set_shader_param("width", 0.0)

func make_target(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		PlayerVars.set_target(self)
		sprite.material.set_shader_param("width", 1.0)
		
