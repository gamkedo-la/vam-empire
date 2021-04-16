extends Container

# export(type, min, max, step)
# Class members can be exported, this means their value gets saved along with the resource (such as the scene) they're attached to. 
# They will also be available for editing in the property editor.
# https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_exports.html
export(Vector2) var NorthPosition = Vector2.ZERO  # The compass points at this position aka North
export(float) var WiggleRange := 0.05
export(float) var WiggleDelaySecondsRange := 0.5

var PlayerPosition = Vector2.ZERO
var Wiggle = 0;

# onready var my_label = get_node("MyLabel") 
# A scene's subnodes can't be accessed until _ready() is entered. The onready keyword, defers variable initialization until _ready() is called.
# https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#onready-keyword
onready var Needle := get_node("Needle")
onready var WiggleTimer := $WiggleTimer
onready var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	PlayerPosition = Global.player_position
	
	# Randomize a tiny bit so the needle has some juice
	if(WiggleTimer.is_stopped()) :
		Wiggle = rng.randf_range(-WiggleRange, WiggleRange)
		WiggleTimer.start(rng.randf_range(0, WiggleDelaySecondsRange))
	
	# Do some math to recalculate the Pointer orientation
	Needle.rotation = Global.player_position.angle_to_point(NorthPosition) - 1.570796 + Wiggle
	
# Not sure what I've done wrong declaring these param
#func SetNorthPosition(Position2D northPosition):
func SetNorthPosition(northPosition):
	NorthPosition = northPosition
