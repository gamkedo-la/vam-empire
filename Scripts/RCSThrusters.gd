extends Node2D

onready var breaks = $Breakes
onready var right = $Right
onready var right1 = $Right/RightRCS
onready var right2 = $Right/LeftRCS
onready var left = $Left
onready var left1 = $Left/RightRCS
onready var left2 = $Left/LeftRCS

func do_break(amount:int):
	if amount > 1:
		amount = 1
	
	if amount <= 0:
		breaks.visible = false
	elif !breaks.visible:
		breaks.visible = true
	
	breaks.scale.x = amount
	breaks.scale.y = amount

func bank_right(amount:int):
	if amount > 1:
		amount = 1
	
	if amount <= 0:
		right.visible = false
	elif !right.visible:
		right.visible = true
	
	right1.scale.x = 0.7 * amount
	right1.scale.y = 0.7 * amount
	
	right2.scale.x = 0.7 * amount
	right2.scale.y = 0.7 * amount

func bank_left(amount:int):
	if amount > 1:
		amount = 1
	
	if amount <= 0:
		left.visible = false
	elif !left.visible:
		left.visible = true
	
	left1.scale.x = 0.7 * amount
	left1.scale.y = 0.7 * amount
	
	left2.scale.x = 0.7 * amount
	left2.scale.y = 0.7 * amount
