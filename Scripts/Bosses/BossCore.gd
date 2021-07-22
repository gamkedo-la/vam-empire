extends Node2D

onready var vanad_core = $VanadCore
onready var boss_hud = $BossHUD/BossUI
onready var targ_detect = null
onready var core_shield = $BossHUD/BossUI2/VBoxContainer/HBoxContainer/CoreShield
onready var core_timer = $VanadCoreTimer
onready var launched_fighter = preload("res://Enemies/Scenes/Small/SingleImpalerSpawn.tscn")

onready var spawners = $Spawners
var spawn_nodes = []

var core_shield_rect_w: int = 0
var actor: Actor = null
var ai: AIController = null
var steering = null

var vanad_core_hp: int = 1000
var vanad_core_is_up: bool = true


func _ready():
	boss_hud.visible = false
	spawn_nodes = spawners.get_children()
	core_shield.value = vanad_core_hp
	if not vanad_core.is_connected("area_entered", self, "on_VanadCore_hit"):
		assert(vanad_core.connect("area_entered", self, "on_VanadCore_hit") == OK)
	targ_detect = get_node_or_null("../AI/TargetDetect")
#	print_debug("targ_detect: ", targ_detect)
	if targ_detect != null && not targ_detect.is_connected("body_entered", self, "show_boss_HUD"):
		print_debug("getting here")
		assert(targ_detect.connect("body_entered", self, "show_boss_HUD") == OK)
		assert(targ_detect.connect("body_exited", self, "hide_boss_HUD") == OK)
	

	pass # Replace with function body.

func initialize(_actor: Actor, _ai: AIController) -> void:
	actor = _actor
	ai = _ai

func on_VanadCore_hit(area: Area2D) -> void:
	var hitparent = area.get_parent()
	
	if hitparent.is_in_group("can_mine"):
		vanad_core_hp -= 20
		core_shield.value = vanad_core_hp
		print_debug("vanad_core_hp: ", vanad_core_hp)
	else:
		pass
	
	if vanad_core_hp <= 0:
		launch_fighters()
		vanad_core_hp = 1000
		core_shield.value = vanad_core_hp

func launch_fighters() -> void:
	for posnode in spawn_nodes:
		var fighter = launched_fighter.instance()
		call_deferred("add_child", fighter)
		fighter.call_deferred("set", "global_position", posnode.global_position)
		fighter.call_deferred("set_as_toplevel", true)
	
func enable_hit_box() -> void:
	if not self.actor.hit_box.is_connected("area_entered", self, "_on_HitBox_area_entered"):
		assert(self.actor.hit_box.connect("area_entered", self, "_on_HitBox_area_entered") == OK)

func disable_hit_box() -> void:
	if self.actor.hit_box.is_connected("area_entered", self, "_on_HitBox_area_entered"):
		assert(self.actor.hit_box.disconnect("area_entered", self, "_on_HitBox_area_entered") == OK)

func show_boss_HUD(body: Node) -> void:
	if body.is_in_group("player"):
		boss_hud.visible = true

func hide_boss_HUD(body: Node) -> void:
	if body.is_in_group("player"):
		boss_hud.visible = false
		
func _on_HitBox_area_entered(area:Area2D) -> void:
	
	pass
