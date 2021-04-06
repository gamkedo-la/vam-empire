extends Node2D

export (String) var ship_name
export (int, 0, 3200) var ACCELERATION = 150
export (int, 0, 1000) var MAX_SPEED = 320
export (int, 0, 200) var FRICTION = 0
export (int, 0, 200) var MASS = 100
export var ROT_SPEED = deg2rad(2)
export var ROT_ACCEL = deg2rad(0)

export (float, 0, 400) var shieldHealth = 200
export (float, 0, 600) var hullHealth = 250
export (float, 0, 150) var energyReserve = 100
