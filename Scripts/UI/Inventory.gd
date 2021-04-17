extends Control




func _on_ExitInventory_pressed():
	if self.visible:
		self.visible = false
		Global.pause_game(false)
	else:
		self.visible = true
		Global.pause_game(true)
