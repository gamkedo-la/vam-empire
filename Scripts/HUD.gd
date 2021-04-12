extends MarginContainer

export (NodePath) var player
onready var p = get_node(player)

onready var shieldHealthBar = $HudVbox/ShieldHBox/Shields
onready var hullHealthBar = $HudVbox/HealthHbox/Health
onready var energyReserveBar = $HudVbox/EnergyHbox/Energy
onready var currencyText = $HudVbox/CurrencyHBox/CurrencyRichText

func _ready():
	if p:
		refresh_bar()
		_refresh_settings()
		UserSettings.connect("ui_refresh", self, "_refresh_settings")
		
	
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

func _refresh_settings():
	shieldHealthBar.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
	hullHealthBar.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
	energyReserveBar.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
	currencyText.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
