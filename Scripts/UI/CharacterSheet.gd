extends Panel
var player_node

onready var statbox = load("res://UI/HUD/Scenes/StatHBox.tscn")
onready var char_vbox = $CharVBox

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
			

func add_sheetStat(name, value):
	var new_statbox = statbox.instance()
	char_vbox.add_child(new_statbox)
	var labl = new_statbox.get_node_or_null("StatLabel")
	var statbox = new_statbox.get_node_or_null("StatEdit")
	labl.set_text(str(name))
	statbox.set_text(str(value))
	


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
