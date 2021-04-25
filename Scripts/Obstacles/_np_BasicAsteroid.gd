extends RigidBody2D
# Similar to BasicAsteroid with no RigidBody

#signal to alert minimap and any other connected objects on removal
signal removed

var ImpulseMag = 70
var ROT_SPEED = 10
var ROT_ACCEL = 1
export var health = 200
var target_orbit

onready var sprite = $Sprite
onready var timer = Timer.new()
var rng = RandomNumberGenerator.new()
var interval

func _ready():
	rng.randomize()
	interval = rng.randf_range(0.1,0.5)
	add_to_group("mini_map")	
	
	add_child(timer)
	#timer.autostart = true
	timer.wait_time = interval
	timer.connect("timeout", self, "_impulse")
	timer.start()
	
	sprite.material.set_shader_param("textureName_size", sprite.texture.get_size())
	angular_velocity = rand_range(-8.0, 8.0)
	angular_damp = 0.0

func _process(_delta):
	if health < 0:
		_free_asteroid()
	
func _impulse():
	if target_orbit:
		#print_debug("Getting here")
		var targ = target_orbit.global_position
		rotate_to_target(targ)
		var dir = Vector2(1, 0).rotated(self.global_rotation)
		apply_central_impulse(dir * (ImpulseMag))
		timer.stop()
		#timer.start()
	

func _free_asteroid():
	emit_signal("removed", self)
	if PlayerVars.get_target() == self:
		PlayerVars.set_target(null)
	#queue_free()


func _on_HurtBox_area_entered(area):
	var hitParent = area.get_parent()
	health -= hitParent.Damage
	hitParent.hit_something()

func unset_target():
	if sprite.material.get_shader_param("width") > 0.0:
		sprite.material.set_shader_param("width", 0.0)

func make_target(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
#		var player = get_node("/root/World/Player")
#		player.player_target = self
		PlayerVars.set_target(self)
		sprite.material.set_shader_param("width", 1.0)

func register_target(targ):
	target_orbit = targ

func rotate_to_target(target):

	if self.get_angle_to(target) > ROT_SPEED:
		self.rotation += ROT_SPEED + ROT_ACCEL
	else:
		self.rotation -= ROT_SPEED + ROT_ACCEL
		
	if abs(self.get_angle_to(target)) < ROT_SPEED * 1.1:
		self.look_at(target)
		ROT_ACCEL = deg2rad(0)
	else:
		ROT_ACCEL += deg2rad(.05)


func _on_MedAsteroid01_input_event(viewport, event, shape_idx):
	make_target(viewport, event, shape_idx)
