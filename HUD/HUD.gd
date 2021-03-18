extends MarginContainer

export (NodePath) var player
onready var p = get_node(player)

onready var shieldHealthBar = $HudVbox/ShieldHBox/Shields
onready var hullHealthBar = $HudVbox/HealthHbox/Health
onready var energyReserveBar = $HudVbox/EnergyHbox/Energy

func _ready():
	if p:
		refresh_bar()
		
	
func _process(_delta):
	if p:
		refresh_bar()
	else:
		p = get_node(player)
	
		
		
func refresh_bar():
	if p.shieldMaxHealth:
		shieldHealthBar.value = (p.shieldHealth / p.shieldMaxHealth) * 100
		hullHealthBar.value = (p.hullHealth / p.hullMaxHealth) * 100
		energyReserveBar.value = (p.energyReserve / p.energyMax) * 100

	
