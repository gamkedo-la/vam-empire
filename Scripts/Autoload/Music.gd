extends Node


onready var ambient_explo_music: AudioStreamPlayer = $Ambient_Exploration
onready var impending_threat: AudioStreamPlayer = $ImpendingThreat
onready var active_combat: AudioStreamPlayer = $ActiveCombat
onready var tween = $Tween

var fade_speed := 20

var ambient_target = 0
var impending_target = -80
var combat_target = -80

var easein_time = 4
var total_near: int = 0
var total_engaged: int = 0
var total_inrange: int = 0
var enem

func _ready():
	# Ease the music in to avoid 'startling' the player on game load
	#Option #1 For Easing options check out http://easings.net
	tween.interpolate_property(
		ambient_explo_music,
		"volume_db",
		ambient_explo_music.volume_db, 0, easein_time,Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.start()
	
	# Option #2 (uncomment and comment above block)
#	ambient_explo_music.volume_db = 0
	pass

func _process(delta: float) -> void:
	
	_set_targets()
	_set_levels(delta)
	pass

func register_enemy(newEnemy: AIController) -> void:
	if not newEnemy.is_connected("state_changed", self, "_enemy_state_changed"):
		assert(newEnemy.connect("state_changed", self, "_enemy_state_changed") == OK)
	if not newEnemy.is_connected("near_player", self, "_impending_threat"):
		assert(newEnemy.connect("near_player", self, "_impending_threat") == OK)


func _enemy_state_changed(state:int) -> void:
	if state != AIController.State.ENGAGE && total_engaged > 0:
		total_engaged -= 1
		if total_inrange > 0:
			total_inrange -= 1
	elif state == AIController.State.ENGAGE:
		total_engaged += 1

func _impending_threat(_inrange: bool) -> void:
	if _inrange: 
		total_inrange += 1
	elif total_inrange > 0:
		total_inrange -= 1
	
	

#	print_debug("Targets-- Ambient: ", ambient_target, "Impending: ", impending_target, "Combat: ", combat_target)
		
func _set_targets() -> void:
	if total_engaged > 0:
		var combat_pct = clamp(total_engaged/2, 0.75, 1.0)
		ambient_target = -40
		impending_target = 0
		combat_target = -80 + (80 * combat_pct)
#		print_debug("Combat Target: ", combat_target, "Combat Pct: ", combat_pct)
	elif total_inrange > 0:
		ambient_target = -20
		impending_target = -5
	else:
		ambient_target = 0
		impending_target = -80
		combat_target = -80
		
	pass

func _set_levels(delta: float) -> void:
	var fade_this_frame = fade_speed * delta
	
	if ambient_explo_music.volume_db < ambient_target - fade_this_frame:
		ambient_explo_music.volume_db += fade_this_frame
	if ambient_explo_music.volume_db > ambient_target + fade_this_frame:
		ambient_explo_music.volume_db -= fade_this_frame
	
	if impending_threat.volume_db < impending_target - fade_this_frame:
		impending_threat.volume_db += fade_this_frame
	if impending_threat.volume_db > impending_target + fade_this_frame:
		impending_threat.volume_db -= fade_this_frame
	
	if active_combat.volume_db < combat_target - fade_this_frame:
		active_combat.volume_db += fade_this_frame
	if active_combat.volume_db > combat_target + fade_this_frame:
		active_combat.volume_db -= fade_this_frame
		
	pass
