extends CanvasLayer

signal can_start
signal can_exit

export var auto_start = true

onready var animator = $AnimationPlayer
onready var rect = $ColorRect

func _ready():
	if auto_start:
		_transition_in()

func transition_out():
	rect.visible = true
	animator.play("Fade Out")

func _transition_in():
	rect.visible = true
	animator.play("Fade In")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade Out":
		emit_signal("can_exit")
		rect.visible = false
		
	if anim_name == "Fade Out":
		emit_signal("can_start")
		rect.visible = false
