extends ColorRect

export (String) var indicator_string

onready var tween = Tween.new()

func _ready():
	print_debug(PlayerVars.mission_state)
	print_debug(PlayerVars.first_use)
	if PlayerVars.first_use.has(indicator_string):
		print_debug(PlayerVars.first_use)
		call_deferred("queue_free")
		return
	_setup()
	
func _setup() -> void:
	var _parent_button = get_parent()
	if _parent_button.has_signal("pressed"):
		if not _parent_button.is_connected("pressed", self, "_disable_indicator"):
			assert(_parent_button.connect("pressed", self, "_disable_indicator") == OK)
	show_behind_parent = true
	rect_size.x = _parent_button.rect_size.x + 5
	rect_size.y = _parent_button.rect_size.y + 5
	rect_position.x -= 2.5
	rect_position.y -= 2.5
	add_child(tween)
	_start_pulse_tween()

func _start_pulse_tween() -> void:
	
	if not tween.is_connected("tween_all_completed", self, "_reverse_tween"):
		assert(tween.connect("tween_all_completed", self, "_reverse_tween") == OK)
	tween.interpolate_property(self, "color:a8", self.color.a8, 0, 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)	
	tween.start()

func _reverse_tween() -> void:
	print_debug(PlayerVars.first_use)
#	print_debug("Definitely getting here...")
	var targ_alpha: int = 0
	if self.color.a8 <= 10:
		targ_alpha = 255
	tween.interpolate_property(self, "color:a8", self.color.a8, targ_alpha, 2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
		
func _disable_indicator() -> void:
	PlayerVars.first_use[indicator_string] = true
	PlayerVars.save()
	call_deferred("queue_free")
