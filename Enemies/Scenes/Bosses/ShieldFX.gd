extends Node2D

var bolts = []
onready var rnd = RandomNumberGenerator.new()
onready var timer = Timer.new()
onready var corelight:Light2D = $CoreEnergy
onready var tween:Tween = Tween.new()
var countdown: float = 0.0
var rand_time: float = 0.0

func _ready():
	rnd.randomize()
	add_child(tween)

	if not timer.is_connected("timeout", self, "_shuffle_bolts"):
		assert(timer.connect("timeout", self, "_shuffle_bolts") == OK)
	if not tween.is_connected("tween_all_completed", self, "_core_pulse"):
		assert(tween.connect("tween_all_completed", self, "_core_pulse") == OK)

	for child in get_children():
		if child is Sprite:
			bolts.append(child)

	rand_time = rnd.randf_range(0.1, 3.0)
	
	tween.interpolate_property(corelight, "energy", 1, 10, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(corelight, "texture_scale", 1, 7, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func _process(delta: float) -> void:
	countdown += delta
	if countdown >= rand_time:
		for bolt in bolts:
			rnd.randomize()
			bolt.rotation_degrees += rnd.randi_range(-90,90)
			bolt.material.set_shader_param("width", rnd.randf_range(0.15, 0.4))
			bolt.material.set_shader_param("size", rnd.randf_range(0.0001, 0.005))
			bolt.material.set_shader_param("cycle", rnd.randi_range(2, 10))
			bolt.material.set_shader_param("time_shift", rnd.randi_range(0, 20))
			rand_time = rnd.randf_range(0.1, 3.0)
			countdown = 0.0 

func _core_pulse() -> void:
	if corelight.energy <= 1.1:
		tween.interpolate_property(corelight, "energy", 1, 10, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.interpolate_property(corelight, "texture_scale", 1, 7, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		tween.interpolate_property(corelight, "energy", 10, 1, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.interpolate_property(corelight, "texture_scale", 7, 1, 2.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)

	tween.start()
