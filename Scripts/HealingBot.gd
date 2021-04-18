extends Sprite




#Parent needs to have:
#healingEnergy
#healingEnergyRecoveryPerTimeUnit
#healingMaxEnergy
#hullHealth
#hullMaxHealth
#shieldHealth
#shieldMaxHealth

onready var parentNode = get_parent() 
var isHealing = false
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_key_pressed(KEY_H)):
		isHealing = true
		heal_parent()
		self.visible = true
	else:
		isHealing = false
		self.visible = false


func _on_HealingTimer_timeout():
	if(!isHealing):
		parentNode.healingEnergy = min(parentNode.healingEnergy + parentNode.healingEnergyRecoveryPerTimeUnit, parentNode.healingMaxEnergy)
		#print("Healing Energy : ", parentNode.healingEnergy)

func heal_parent():
	if(parentNode.healingEnergy > 0):
		if(parentNode.hullHealth < parentNode.hullMaxHealth):
			parentNode.hullHealth = min(parentNode.hullHealth + 1, parentNode.hullMaxHealth)
			parentNode.healingEnergy-=1
		elif (parentNode.shieldHealth < parentNode.shieldMaxHealth):
			parentNode.shieldHealth = min(parentNode.shieldHealth + 1, parentNode.shieldMaxHealth)
			parentNode.healingEnergy-=1
	print("Heal: ", parentNode.hullHealth)
	print("Shield: ", parentNode.shieldHealth)
