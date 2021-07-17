extends Node2D

onready var vanad_core = $VanadCore
onready var boss_hud = $BossHUD/BossUI
onready var targ_detect = null


func _ready():
	boss_hud.visible = false
	if not vanad_core.is_connected("area_entered", self, "on_VanadCore_hit"):
		assert(vanad_core.connect("area_entered", self, "on_VanadCore_hit") == OK)
	targ_detect = get_node_or_null("../AI/TargetDetect")
	print_debug("targ_detect: ", targ_detect)
	if targ_detect != null && not targ_detect.is_connected("body_entered", self, "show_boss_HUD"):
		print_debug("getting here")
		assert(targ_detect.connect("body_entered", self, "show_boss_HUD") == OK)
		assert(targ_detect.connect("body_exited", self, "hide_boss_HUD") == OK)
	

	pass # Replace with function body.


func on_VanadCore_hit(area: Area2D) -> void:
	var hitparent = area.get_parent()
	
	if hitparent.is_in_group("can_mine"):
		pass
	else:
		pass

func show_boss_HUD(body: Node) -> void:
	if body.is_in_group("player"):
		boss_hud.visible = true

func hide_boss_HUD(body: Node) -> void:
	if body.is_in_group("player"):
		boss_hud.visible = false
