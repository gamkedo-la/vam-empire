extends AnimatedSprite

func _ready() -> void:
	self.play("default")
	
func _on_explosion_unlit_animation_finished() -> void:
	call_deferred("queue_free")
