extends Panel

var player_node

onready var debug_vbox = $DebugOptsVBox
onready var frigate_list = $DebugOptsVBox/TabContainer/Ships/VBoxContainer/FrigatesHB/FrigateSelect
onready var destroyer_list = $DebugOptsVBox/TabContainer/Ships/VBoxContainer/DestroyersHB/DestroyerSelect
onready var corvette_list = $DebugOptsVBox/TabContainer/Ships/VBoxContainer/CorvettesHB/CorvetteSelect
onready var dreadnought_list = $DebugOptsVBox/TabContainer/Ships/VBoxContainer/HBoxContainer4/DreadnoughtSelect
var ships
var ship_inv = []

func _ready():
	# Start Hidden
	self.visible = false
	player_node = get_parent().get_parent()
	# Populate Frigates
	var temp_hangar = Global.ship_hangar[0].duplicate()
	for Ship in temp_hangar:		
		frigate_list.add_item(Ship[0].ship_name)
	temp_hangar = Global.ship_hangar[1].duplicate()
	for Ship in temp_hangar:		
		destroyer_list.add_item(Ship[0].ship_name)
	temp_hangar = Global.ship_hangar[2].duplicate()
	for Ship in temp_hangar:		
		corvette_list.add_item(Ship[0].ship_name)
	temp_hangar = Global.ship_hangar[3].duplicate()
	for Ship in temp_hangar:		
		dreadnought_list.add_item(Ship[0].ship_name)
	var _connect = PlayerVars.connect("mission_complete", self, "_mission_complete")
		

func _process(_delta):
	if Input.is_action_just_pressed("debug_menu"):
		if !self.visible:
			self.visible = true
		else:
			self.visible = false
			# in case the mouse was over the panel when it closes
			Global.set_hold_fire(false)

func _mission_complete() -> void:
	self.visible = false
	Global.set_hold_fire(false)

func _on_PlayerDebugMenu_mouse_entered():
	Global.set_hold_fire(true)

func _on_PlayerDebugMenu_mouse_exited():
	Global.set_hold_fire(false)

func _on_TopBar_mouse_entered():
	Global.set_hold_fire(true)

func _on_TopBar_mouse_exited():
	Global.set_hold_fire(false)

func _on_ShipSelect_mouse_entered():
	Global.set_hold_fire(true)

func _on_ShipSelect_mouse_exited():
	Global.set_hold_fire(false)


func _on_ShipSelect_item_selected(index):
	var newShip = Global.ship_hangar[0][index].duplicate(true)
	player_node.pilot_ship_from_pack(newShip[0].duplicate())
	PlayerVars.save_ship_idx(0, index)

func _on_DestroyerSelect_item_selected(index):
	var newShip = Global.ship_hangar[1][index].duplicate(true)
	player_node.pilot_ship_from_pack(newShip[0].duplicate())
	PlayerVars.save_ship_idx(1, index)
func _on_CorvetteSelect_item_selected(index):
	var newShip = Global.ship_hangar[2][index].duplicate(true)
	player_node.pilot_ship_from_pack(newShip[0].duplicate())
	PlayerVars.save_ship_idx(2, index)
	
func _on_DreadnoughtSelect_item_selected(index):
	var newShip = Global.ship_hangar[3][index].duplicate(true)
	player_node.pilot_ship_from_pack(newShip[0].duplicate())
	PlayerVars.save_ship_idx(3, index)
	


# Take Damage Debug
func _on_TakeDamage10_pressed():
	player_node.take_damage(10)

func _on_TakeDamage25_pressed():
	player_node.take_damage(25)

func _on_TakeDamage50_pressed():
	player_node.take_damage(50)


func _on_SuccessMission2_pressed():
	PlayerVars.emit_signal("mission_complete")
