extends ParallaxLayer

onready var background_texture: Sprite = $Texture3D
onready var scene_3d: Viewport = $Scene3D

var texture

func _ready():
	texture = scene_3d.get_texture()
	background_texture.texture = texture
	

