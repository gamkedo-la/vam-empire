extends Panel

var player_node

export(PackedScene) var ship_hangar
onready var debug_vbox = $DebugOptsVBox
onready var ship_list = $DebugOptsVBox/HBoxContainer/ShipSelect
var ships
var ship_inv = []

func _ready():
	# Start Hidden
	self.visible = false
	player_node = get_parent().get_parent()
	if ship_hangar:
		ships = ship_hangar.instance()
		for Class in ships.get_children():
			var subclass_ships = Class.get_children()
			for Ship in subclass_ships:
				ship_list.add_item(Ship.get_child(0).ship_name)
				ship_inv.append(Ship.get_child(0))

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
	player_node.pilot_ship_from_pack(ship_inv[index].duplicate())
