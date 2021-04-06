extends Panel
var player_node

func _ready():
	# Start Hidden
	self.visible = false
	player_node = get_tree().get_root().get_node_or_null("Player")
	

func _process(_delta):
	if Input.is_action_just_pressed("ui_charpanel"):
		if !self.visible:
			self.visible = true
		else:
			self.visible = false
			# in case the mouse was over the panel when it closes
			Global.hold_fire(false)
			


# Is there a better way to keep "left click" from firing? Not sure... 
# but using a Global.hold_fire variable to disable the "ui_attack" action while mouse is over the character sheet
func _on_TopBar_mouse_entered():
	Global.hold_fire(true)

func _on_TopBar_mouse_exited():
	Global.hold_fire(false)

func _on_CharacterSheet_mouse_entered():
	Global.hold_fire(true)

func _on_CharacterSheet_mouse_exited():
	Global.hold_fire(false)
