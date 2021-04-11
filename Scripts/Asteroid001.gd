extends RigidBody2D

export var health = 200
var TOD = false

#onready var tween = $Fog/Tween
var fog = null
var tween = null

func _ready():
	add_to_group("asteroids")	
	TOD = Global.day
	if !fog:
		fog = get_node_or_null("Fog")
		if fog:
			tween = get_node_or_null("Fog/Tween")
			if tween:
				adjust_for_tod()		


func _process(_delta):
	if health < 0:
		queue_free()		
	if tween:
		if TOD != Global.day:
			TOD = Global.day
			adjust_for_tod()


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

func make_target(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var player = get_node("/root/World/Player")
		player.player_target = self

func adjust_for_tod():
	var current_sm = self_modulate
	if $Fog:
		if Global.day:			
			tween.interpolate_property($Fog,"self_modulate:a8", $Fog.self_modulate.a8, 1, 40, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			tween.start()
			#$Fog.self_modulate.a8 = 5
		else:			
			tween.interpolate_property($Fog,"self_modulate:a8", $Fog.self_modulate.a8, 75, 40, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			tween.start()
			#$Fog.self_modulate.a8 = 75
	
