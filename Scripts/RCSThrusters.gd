extends Node2D

onready var brakes = $Breakes
onready var right = $Right
onready var right1 = $Right/RightRCS
onready var right2 = $Right/LeftRCS
onready var left = $Left
onready var left1 = $Left/RightRCS
onready var left2 = $Left/LeftRCS

func do_break(amount:float):
	if amount > 1:
		amount = 1
	
	if amount <= 0:
		brakes.visible = false
		Effects.emit_signal("RCSFront", false, 0.0)
	elif !brakes.visible:
		brakes.visible = true

	brakes.scale.x = amount
	brakes.scale.y = amount
	
	if brakes.visible:
		Effects.emit_signal("RCSFront", true, amount)

func bank_right(amount:float):
	if amount > 1:
		amount = 1
	
	if amount <= 0:
		right.visible = false
		Effects.emit_signal("RCSLeft", false, 0.0)
		Effects.emit_signal("RCSRight", false, 0.0)
	elif !right.visible:
		right.visible = true

	
	right1.scale.x = 0.7 * amount
	right1.scale.y = 0.7 * amount
	
	right2.scale.x = 0.7 * amount
	right2.scale.y = 0.7 * amount
	if right.visible:
		Effects.emit_signal("RCSLeft", true, amount)
		Effects.emit_signal("RCSRight", true, amount*0.3)

func bank_left(amount:float):
	if amount > 1.0:
		amount = 1.0
	
	if amount <= 0:
		left.visible = false
		Effects.emit_signal("RCSLeft", false, 0.0)
		Effects.emit_signal("RCSRight", false, 0.0)
	elif !left.visible:
		left.visible = true

	
	left1.scale.x = 0.7 * amount
	left1.scale.y = 0.7 * amount
	
	left2.scale.x = 0.7 * amount
	left2.scale.y = 0.7 * amount
	if left.visible:
		Effects.emit_signal("RCSLeft", true, amount*0.3)
		Effects.emit_signal("RCSRight", true, amount)
