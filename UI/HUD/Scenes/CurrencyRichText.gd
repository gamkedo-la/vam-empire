extends RichTextLabel

onready var playerVars = get_node("/root/PlayerVars")

func _ready():
	pass # Replace with function body.

func _process(delta):
	get_node("/root/World/CanvasLayer/HUD/HudVbox/CurrencyHBox/CurrencyRichText").bbcode_text = "[color=yellow]$[/color]" + String(playerVars.player["cash"])
