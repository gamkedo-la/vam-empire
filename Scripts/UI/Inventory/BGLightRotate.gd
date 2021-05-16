extends CSGSphere

onready var light_pivot: Position3D = $LightPivot
onready var light_tween:Tween = $LightPivot/Tween

func _ready():
	light_tween.interpolate_property(light_pivot,"rotation_degrees",
										light_pivot.rotation_degrees, 720, 5,
										Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	light_tween.start()
