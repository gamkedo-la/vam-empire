extends Path2D


export (int, 10, 1000) var ring_density = 10
export (float, 1, 100) var ring_speed = 1

var asteroid = load("res://Obstacles/Scenes/_np_MedAsteroid01.tscn")
var follow_agent = load("res://Obstacles/Scenes/AsteroidRingFollower.tscn")

onready var rng = RandomNumberGenerator.new()
onready var asteroid_agents = []
onready var parent_node = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	var density = 1000 / ring_density 
	for roid in range(1, 1000, density):
		rng.randomize()
		var vert_offset = rng.randi_range(-280,280)
		rng.randomize()
		var hori_offset = rng.randi_range(-100, 100)
		#print("roid: ", roid)
		var new_roid =  asteroid.instance()
		var new_followagent = follow_agent.instance()
		var new_postarg = Position2D.new()
		add_child(new_followagent)
		new_followagent.add_child(new_postarg)
		new_followagent.unit_offset = float(roid) / 1000
		new_followagent.v_offset = vert_offset
		new_followagent.h_offset = hori_offset
		#print("unit_offset: ", new_followagent.unit_offset, " roid/1000: ", float(roid)/1000)
		parent_node.call_deferred("add_child",new_roid)
		new_roid.register_target(new_postarg)
		new_roid.global_position = new_postarg.global_position
		new_roid.global_rotation = new_postarg.global_rotation
		asteroid_agents.append(new_followagent)
	#print(asteroid_agents.size())
#
#func _process(delta):
#	for roid in asteroid_agents:
#		roid.offset += ring_speed + delta
		
