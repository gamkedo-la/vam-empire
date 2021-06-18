extends PanelContainer

onready var animator = $AnimationPlayer

onready var name_label = $MainVBoxContainer/PortraitAndShipHBoxContainer/MarginContainer/PortraitContainer/NameLabel
onready var ship_name_label =$MainVBoxContainer/PortraitAndShipHBoxContainer/VBoxContainer/ShipNameHBox/Ship
onready var ship_class_label =$MainVBoxContainer/PortraitAndShipHBoxContainer/VBoxContainer/ShipClassHBox/Label

# Left column
onready var hull_label = $MainVBoxContainer/StatsHBox/LeftColumn/HullHBox/Label
onready var shield_label = $MainVBoxContainer/StatsHBox/LeftColumn/ShieldHBox/Label
onready var acceleration_label = $MainVBoxContainer/StatsHBox/LeftColumn/AccelerationHBox/Label
onready var max_speed_label = $MainVBoxContainer/StatsHBox/LeftColumn/MaxSpeedHBox/Label
onready var rotation_speed_label = $MainVBoxContainer/StatsHBox/LeftColumn/RotationSpeedHBox/Label

# Right Column
onready var energy_label = $MainVBoxContainer/StatsHBox/RightColumn/EnergyHBox/Label
onready var energy_recovery_label = $MainVBoxContainer/StatsHBox/RightColumn/EnergyRecoveryHBox/Label
onready var friction_label = $MainVBoxContainer/StatsHBox/RightColumn/FrictionHBox/Label
onready var mass_label = $MainVBoxContainer/StatsHBox/RightColumn/MassHBox/Label
onready var hardpoints_label = $MainVBoxContainer/StatsHBox/RightColumn/HardpointsHBox/Label

const PLAYER_VARS_SIGNAL_NAMES = [
	"shield_health_changed",
	"shield_max_health_changed",
	"hull_health_changed",
	"hull_max_health_changed",
	"energy_reserve_changed",
	"energy_max_reserve_changed"
];

func _ready():
	# Start Hidden
	name_label.text = PlayerVars.player.name
	for _signal in PLAYER_VARS_SIGNAL_NAMES:
		var _connect = PlayerVars.connect(_signal, self, "on_value_changed");

func on_value_changed(_val, _change_amount):
	# signals call with two args, which we don't need
	update_values()

# tell the Character sheet the player is ready to grab stats from
func update_values():
	set_label_text(hull_label, "%.2f/%.2f" % [PlayerVars.hull_health, PlayerVars.hull_max_health])
	set_label_text(shield_label, "%.2f/%.2f" % [PlayerVars.shield_health, PlayerVars.shield_max_health])
	set_label_text(energy_label, "%.2f/%.2f KWh" % [PlayerVars.energy_reserve, PlayerVars.energy_max_reserve])
	set_label_text(energy_recovery_label, "%.2f KWh/s" % [PlayerVars.energy_recovery_per_s])
	
	var _player = PlayerVars.player_node
	if _player is Player:
		set_label_text(acceleration_label, "%.2f m/s^2" % [_player.ACCELERATION])
		set_label_text(max_speed_label, "%.2f m/s" % [_player.MAX_SPEED])
		set_label_text(rotation_speed_label, "%.2f deg/s" % [_player.ROT_SPEED])
		set_label_text(friction_label, "%.2f m/s^2" % [_player.FRICTION])
		set_label_text(mass_label, "%.2f Tonnes" % [_player.MASS])
		set_label_text(hardpoints_label, "%d" % [_player.piloted_ship.hardpoints.get_child_count() if _player.piloted_ship.hardpoints != null else 0])

func _process(_delta):
	if Input.is_action_just_pressed("ui_charpanel"):
		if !self.visible:
			self.visible = true
			animator.play("Show")
		else:
			animator.play("Hide")
			# in case the mouse was over the panel when it closes
			Global.set_hold_fire(false)

func set_label_text(label, text):
	label.text = text

# Is there a better way to keep "left click" from firing? Not sure... 
# but using a Global.set_hold_fire variable to disable the "ui_attack" action while mouse is over the character sheet
func _on_TopBar_mouse_entered():
	Global.set_hold_fire(true)

func _on_TopBar_mouse_exited():
	Global.set_hold_fire(false)

func _on_CharacterSheet_mouse_entered():
	Global.set_hold_fire(true)

func _on_CharacterSheet_mouse_exited():
	Global.set_hold_fire(false)
