extends Panel
var player_node
var isVisable = false

onready var statbox = load("res://UI/HUD/Scenes/StatHBox.tscn")
onready var animator = $AnimationPlayer
onready var char_vbox = $CharVBox
onready var char_topbar_lbl = $TopBar/Label

func _ready():
	# Start Hidden
	player_node = get_parent().get_parent()
	char_topbar_lbl.text = "Character: " + PlayerVars.player.name
	

func _process(_delta):
	if Input.is_action_just_pressed("ui_charpanel"):
		if !isVisable:
			isVisable = true
			animator.play("Show")
		else:
			isVisable = false
			animator.play("Hide")
			# in case the mouse was over the panel when it closes
			Global.set_hold_fire(false)
			

func add_sheetStat(name, value):
	var new_statbox = statbox.instance()
	char_vbox.add_child(new_statbox)
	var labl = new_statbox.get_node_or_null("StatLabel")
	var stat_edit = new_statbox.get_node_or_null("StatEdit")
	labl.set_text(str(name))
	stat_edit.set_text(str(value))
	


# Is there a better way to keep "left click" from firing? Not sure... 
# but using a Global.set_hold_fire variable to disable the "ui_attack" action while mouse is over the character sheet
func _on_TopBar_mouse_entered():
	Global.set_hold_fire(true)

func _on_TopBar_mouse_exited():
	Global.set_hold_fire(false)

func _on_CharacterSheet_mouse_entered():
	Global.set_hold_fire(true)

func _on_CharacterSheet_mouse_exited():
	Global.set_hold_fire(false)
