class_name MineralDroid
extends KinematicBody2D

signal dock_droid

var target: RigidBody2D = null
var carried_mineral: RigidBody2D = null
var droid_bay = null
export (float, 0.035, 300.0) var ROT_SPEED = 0.035
onready var targ_pos := Position2D.new()
export (float, 10.0, 400.0) var MAX_SPEED = 100.0
export (float, 10.0, 500.0) var ACCELERATION = 50.0

var velocity = Vector2.ZERO

func _ready():	
	add_child(targ_pos)
	set_as_toplevel(true)
	if droid_bay:
		global_position = droid_bay.global_position
	if target:
		var _connected = target.connect("removed", self, "_target_removed")

func _physics_process(delta: float):
	if target:
		_rotate_to_target(target.global_position)
		_check_pickup()
	else:
		_rotate_to_target(droid_bay.global_position)
		_check_bay()
	_move(delta)
	
		

func _check_pickup() -> void:
	if global_position.distance_to(target.global_position) < 1:
		Global.reparent(target, self)
		target.global_position = global_position
		carried_mineral = target
		target = null

func _check_bay() -> void:
	if !carried_mineral:
		if global_position.distance_to(droid_bay.global_position) < 3:
			emit_signal("dock_droid")

func _rotate_to_target(_target: Vector2):
	self.look_at(_target)

func _move(delta: float) -> void:
	var thrust_vector = Vector2(1,0)
	thrust_vector = thrust_vector.rotated(global_rotation)
	velocity = velocity.move_toward(thrust_vector * MAX_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)

func _target_removed(_removed_targ) -> void:
	target = null
	carried_mineral = null
	
