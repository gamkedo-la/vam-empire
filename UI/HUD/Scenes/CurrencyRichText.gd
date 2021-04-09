extends RichTextLabel

func _ready():
	pass # Replace with function body.

func _process(_delta):
	self.bbcode_text = "[color=yellow]$[/color]" + String(PlayerVars.player["cash"])
