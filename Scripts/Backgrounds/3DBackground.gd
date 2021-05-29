extends ParallaxLayer

onready var background_texture: Sprite = $Texture3D
onready var scene_3d: Viewport = $PlanetScene

var texture

func _ready() -> void:
	texture = scene_3d.get_texture()
	background_texture.texture = texture
	
func _process(_delta) -> void:
	background_texture.texture = texture
	
	

