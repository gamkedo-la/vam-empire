extends Sprite

export var heal_amount_per_s = 60.0
export var heal_energy_cost_per_s = 60.0

#Parent needs to have:
#heal(amount, energy_cost) function

onready var parentNode = get_parent() 
var isHealing = false
# Called when the node enters the scene tree for the first time.
func _ready():	
	self.visible = false
	
func initialize(player_hull) -> void:
	heal_amount_per_s = player_hull * .05

func _physics_process(_delta):
	if(Input.is_key_pressed(KEY_H)):
		isHealing = true
		heal_parent(heal_amount_per_s * _delta, heal_energy_cost_per_s * _delta)
		self.visible = true
	else:
		isHealing = false
		self.visible = false


func _on_HealingTimer_timeout():
	pass
	# Moved this logic to the player script, but this could come in handy down the line
	# if(!isHealing):
	# 	parentNode.healingEnergy = min(parentNode.healingEnergy + parentNode.healingEnergyRecoveryPerTimeUnit, parentNode.healingMaxEnergy)
	# 	#print("Healing Energy : ", parentNode.healingEnergy)

func heal_parent(amount, energy_cost):
	parentNode.heal(amount, energy_cost)

