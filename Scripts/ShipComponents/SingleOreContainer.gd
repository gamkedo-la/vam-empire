extends Sprite
signal ready_for_work
onready var mineral_droid = preload("res://Ships/Droids/MineralRetrieverAI.tscn")
onready var tween = Tween.new()
var busy: bool = false
var target_mineral: RigidBody2D = null
var droid: MineralDroid = null

func _ready():
	tween.repeat = false
	call_deferred("add_child", tween)
	pass # Replace with function body.

func retrieve_mineral(target:RigidBody2D) -> void:
	var newDroid = mineral_droid.instance()
	_open_ore_container()
	droid = newDroid
	target_mineral = target
	droid.droid_bay = self
	droid.target = target
	call_deferred("add_child", newDroid)	
	droid.connect("dock_droid", self, "_dock_droid")
	busy = true
	

func _open_ore_container() -> void:
	tween.interpolate_property(self, "frame", frame, 8, 3, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()

func _close_ore_container() -> void:
	tween.interpolate_property(self, "frame", frame, 0, 3, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()




func _dock_droid() -> void:
	droid.call_deferred("queue_free")
	busy = false
	target_mineral = null
	droid = null
	emit_signal("ready_for_work", self)
	_close_ore_container()
	
