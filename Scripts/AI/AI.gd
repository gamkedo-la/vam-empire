extends Node2D
signal state_changed(new_state)

onready var player_detect_area = $PlayerDetect
var actor = null
var actor_velocity = Vector2.ZERO
var player: Player = null
var ship: Ship = null

enum State {
	PATROL,
	ENGAGE
}

var current_state: int = State.PATROL setget set_state

func _ready() -> void:
	set_state(State.PATROL)
	

func _physics_process(delta: float) -> void:
	if !actor:
		return
		
	match current_state:
		State.PATROL:
			pass
		State.ENGAGE:
			if player != null and ship != null:
				#actor.rotation = actor.global_position.direction_to(player.global_position)
				actor.rotate_toward(player.global_position)
				if abs(actor.global_position.angle_to(player.global_position)) < 0.1:
					ship.fire_weapons(actor_velocity)
			else:
				print("In engage state but no player/ship")
		_:
			printerr("Error: Found a state for enemy that should not exist", self)

func initialize(newActor, newShip: Ship):
	self.actor = newActor
	self.ship = newShip

func set_state(new_state: int) -> void:
	if new_state == current_state:
		return
		
	current_state = new_state
	emit_signal("state_changed", current_state)

func _on_PlayerDetect_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print_debug("Player detected by enemy: ", self, " player: ", body)
		set_state(State.ENGAGE)
		player = body

