extends Node2D

onready var vanad_core: Area2D = $VanadCore
onready var vanad_core_coll: CollisionShape2D = $VanadCore/CollisionShape2D
onready var boss_hud = $BossHUD/BossUI
onready var targ_detect = null
onready var core_shield = $BossHUD/BossUI2/VBoxContainer/HBoxContainer/CoreShield
onready var shield_hud = $BossHUD/BossUI/VBoxContainer/HBoxContainer/ShieldHealth
onready var hull_hud = $BossHUD/BossUI/VBoxContainer/HBoxContainer2/HullHealth
onready var core_timer: Timer = $VanadCoreTimer
onready var launched_fighter = preload("res://Enemies/Scenes/Small/SingleImpalerSpawn.tscn")

onready var spawners = $Spawners
onready var tween = Tween.new()
var spawn_nodes = []

var core_shield_rect_w: int = 0
var actor: Actor = null
var ai: AIController = null
var steering = null

var vanad_core_hp: int = 1000 setget set_corehp
var vanad_core_is_up: bool = true


func _ready():
	boss_hud.visible = false
	spawn_nodes = spawners.get_children()
	core_shield.value = vanad_core_hp
	call_deferred("add_child", tween)
	if not tween.is_connected("tween_all_completed", self, "_on_tween_all_completed"):
		assert(tween.connect("tween_all_completed", self, "_on_tween_all_completed") == OK)
	if not core_timer.is_connected("timeout", self, "_reset_core_shields"):
		assert(core_timer.connect("timeout", self, "_reset_core_shields") == OK)
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
	shield_hud.max_value = actor.shieldMaxHealth
	hull_hud.max_value = actor.hullMaxHealth
	update_HUD()

func set_corehp(val) -> void:
	vanad_core_hp = val
	core_shield.value = val

func on_VanadCore_hit(area: Area2D) -> void:
	var hitparent = area.get_parent()
	
	if vanad_core_is_up:
		if hitparent.is_in_group("can_mine"):
			vanad_core_hp -= 20
			core_shield.value = vanad_core_hp
	#		print_debug("vanad_core_hp: ", vanad_core_hp)
			if vanad_core_hp <= 0:
				launch_fighters()
				vanad_core_is_up = false
				vanad_core_coll.shape.radius /= 4
				core_timer.start()
		elif hitparent.is_in_group("projectile"):
			hitparent.hit_something()
	else:
		if hitparent.is_in_group("projectile"):
			actor.take_damage(hitparent.Damage)
			update_HUD()
			hitparent.hit_something()
	


func update_HUD() -> void:
	shield_hud.value = actor.shieldHealth
	hull_hud.value = actor.hullHealth

func launch_fighters() -> void:
	for posnode in spawn_nodes:
		var fighter = launched_fighter.instance()
		call_deferred("add_child", fighter)
		fighter.call_deferred("set", "global_position", vanad_core.global_position)
		fighter.call_deferred("set_as_toplevel", true)
		var fighter_ai:Actor = null 
		fighter_ai = get_node_or_null("VampireImpalerAI")
		if fighter_ai != null:
			fighter_ai.set_target(PlayerVars.player_node)
	
func enable_hit_box() -> void:
	if not actor.hit_box.is_connected("area_entered", self, "_on_HitBox_area_entered"):
		assert(actor.hit_box.connect("area_entered", self, "_on_HitBox_area_entered") == OK)

func disable_hit_box() -> void:
	if actor.hit_box.is_connected("area_entered", self, "_on_HitBox_area_entered"):
		assert(actor.hit_box.disconnect("area_entered", self, "_on_HitBox_area_entered") == OK)

func show_boss_HUD(body: Node) -> void:
	if body.is_in_group("player"):
		boss_hud.visible = true

func hide_boss_HUD(body: Node) -> void:
	if body.is_in_group("player"):
		boss_hud.visible = false

func _reset_core_shields() -> void:
	tween.interpolate_property(self, "vanad_core_hp", vanad_core_hp, 1000, 3.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()

func _on_tween_all_completed() -> void:
	vanad_core_coll.shape.radius *= 4
	vanad_core_is_up = true
	
func _on_HitBox_area_entered(area:Area2D) -> void:
	
	pass
