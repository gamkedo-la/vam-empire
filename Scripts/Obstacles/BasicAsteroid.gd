extends RigidBody2D

#signal to alert minimap and any other connected objects on removal
signal removed

export var health = 200

func _ready():
	add_to_group("mini_map")	

func _process(_delta):
	if health < 0:
		_free_asteroid()
	


func _free_asteroid():
	emit_signal("removed", self)
	queue_free()


func _on_HurtBox_area_entered(area):
	var hitParent = area.get_parent()
	health -= hitParent.Damage
	hitParent.hit_something()


func _on_Asteroid001_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func _on_Asteroid002_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func _on_Asteroid003_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)

func make_target(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
#		var player = get_node("/root/World/Player")
#		player.player_target = self
		PlayerVars.player_node.player_target = self
