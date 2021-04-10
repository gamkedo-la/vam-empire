extends Panel

var player_node

onready var debug_vbox = $DebugOptsVBox
onready var frigate_list = $DebugOptsVBox/HBoxContainer/FrigateSelect
onready var destroyer_list = $DebugOptsVBox/HBoxContainer2/DestroyerSelect
onready var corvette_list = $DebugOptsVBox/HBoxContainer3/CorvetteSelect
onready var dreadnought_list = $DebugOptsVBox/HBoxContainer4/DreadnoughtSelect
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
		

func _process(_delta):
	if Input.is_action_just_pressed("debug_menu"):
		if !self.visible:
			self.visible = true
		else:
			self.visible = false
			# in case the mouse was over the panel when it closes
			Global.hold_fire(false)



func _on_PlayerDebugMenu_mouse_entered():
	Global.hold_fire(true)

func _on_PlayerDebugMenu_mouse_exited():
	Global.hold_fire(false)

func _on_TopBar_mouse_entered():
	Global.hold_fire(true)

func _on_TopBar_mouse_exited():
	Global.hold_fire(false)

func _on_ShipSelect_mouse_entered():
	Global.hold_fire(true)

func _on_ShipSelect_mouse_exited():
	Global.hold_fire(false)


func _on_ShipSelect_item_selected(index):
	print("Selected item index: ", index)
	#player_node.pilot_ship_from_pack(ship_inv[index].duplicate())
	var newShip = Global.ship_hangar[0][index].duplicate(true)
	player_node.pilot_ship_from_pack(newShip[0].duplicate())
