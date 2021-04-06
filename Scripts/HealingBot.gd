extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#export (NodePath) var player
#onready var p = get_node(player)
onready var player = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HealingTimer_timeout():
	if(!player.isHealing):
		player.healingEnergy = min(player.healingEnergy + player.healingEnergyRecoveryPerTimeUnit, player.healingMaxEnergy)
		print("Healing Energy : ", player.healingEnergy)
