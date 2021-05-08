extends MarginContainer

export (NodePath) var player

onready var shieldHealthBar = $HudVbox/ShieldHBox/Shields
onready var hullHealthBar = $HudVbox/HealthHbox/Health
onready var energyReserveBar = $HudVbox/EnergyHbox/Energy
onready var currencyText = $HudVbox/CurrencyHBox/CurrencyRichText
onready var shieldAnimationPlayer = $HudVbox/ShieldHBox/AnimationPlayer
onready var hullAnimationPlayer = $HudVbox/HealthHbox/AnimationPlayer

func _ready():
	_refresh_settings()
	UserSettings.connect("ui_refresh", self, "_refresh_settings")

	# Here, we are "binding" default parameters to add to the end of the signal call. 
	# The function will get passed in the the first 2 vars from the signal emission, and then the animation player we want to use, if applicable
	PlayerVars.connect("hull_health_changed", self, "_on_PlayerVars_stat_change", [hullAnimationPlayer])
	PlayerVars.connect("hull_max_health_changed", self, "_on_PlayerVars_stat_change", [null])
	PlayerVars.connect("shield_health_changed", self, "_on_PlayerVars_stat_change", [shieldAnimationPlayer])
	PlayerVars.connect("shield_max_health_changed", self, "_on_PlayerVars_stat_change", [null])	

	PlayerVars.connect("energy_reserve_changed", self, "_on_PlayerVars_stat_change", [null])	
	PlayerVars.connect("energy_max_reserve_changed", self, "_on_PlayerVars_stat_change", [null])	
	
		
func _on_PlayerVars_stat_change(_amount, change_amount, animation_player):
	if PlayerVars.shield_max_health != 0 && PlayerVars.hull_max_health != 0 && PlayerVars.energy_max_reserve != 0:
		shieldHealthBar.value = (float(PlayerVars.shield_health) / float(PlayerVars.shield_max_health)) * 100
		hullHealthBar.value = (float(PlayerVars.hull_health) / float(PlayerVars.hull_max_health)) * 100
		energyReserveBar.value = (float(PlayerVars.energy_reserve) / float(PlayerVars.energy_max_reserve)) * 100

		if animation_player != null && !animation_player.is_playing() && change_amount < 0:
			animation_player.play("Hit")

func _refresh_settings():
	shieldHealthBar.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
	hullHealthBar.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
	energyReserveBar.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
	currencyText.self_modulate.a = UserSettings.current.ui.shipHUD_opacity
