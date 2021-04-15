extends Path2D


export (int, 10, 1000) var ring_density = 10
export (float, 1, 100) var ring_speed = 1

var asteroid = load("res://Obstacles/Scenes/KineMedAsteroid.tscn")

onready var rng = RandomNumberGenerator.new()
onready var asteroid_agents = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var density = 1000 / ring_density 
	for roid in range(1, 1000, density):
		rng.randomize()
		var vert_offset = rng.randi_range(-280,280)
		#print("roid: ", roid)
		var new_roid =  asteroid.instance()
		var new_followagent = PathFollow2D.new()
		add_child(new_followagent)
		new_followagent.unit_offset = float(roid) / 1000
		new_followagent.v_offset = vert_offset
		#print("unit_offset: ", new_followagent.unit_offset, " roid/1000: ", float(roid)/1000)
		new_followagent.add_child(new_roid)
		asteroid_agents.append(new_followagent)
	print(asteroid_agents.size())

func _process(delta):
	for roid in asteroid_agents:
		roid.offset += ring_speed + delta
		
