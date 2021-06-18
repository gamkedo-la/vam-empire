extends Line2D
# Taken and adapted from example by Raffaele Picca - raffaelepicca.com (CC0)
# @ https://www.youtube.com/watch?v=bqyDm0MmGqg (How to make your bullets look awesome in Godot - Advanced Trails)
# Attribution provided to promote his efforts as a Godot educator!

export var limited_lifetime := false
export var wildness := 3.0
export var min_spawn_distance := 5.0
export var gravity := Vector2.UP


var lifetime := [1.2, 1.6]
var tick_speed := 0.05
var tick := 0.0
var wild_speed := 0.1
var point_age := [0.0]
var stopped := false

onready var tween := $Decay

func _ready():
	
	set_as_toplevel(true)
	clear_points()
	if limited_lifetime:
		stop()


func stop():
	stopped = true
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, rand_range(lifetime[0], lifetime[1]), Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()


func _process(delta):
	if tick > tick_speed:
		tick = 0
		for p in range(get_point_count()):
			point_age[p] += 5*delta
			var rand_vector := Vector2( rand_range(-wild_speed, wild_speed), rand_range(-wild_speed, wild_speed) )
			points[p] += gravity + ( rand_vector * wildness * point_age[p] )
		if stopped:

			width += 3
	else:
		tick += delta


func add_point(point_pos:Vector2, at_pos := -1):
	if get_point_count() > 0 and point_pos.distance_to( points[get_point_count()-1] ) < min_spawn_distance:
		return
	
	point_age.append(0.0)
	.add_point(point_pos, at_pos)


func _on_Decay_tween_all_completed():
	queue_free()
