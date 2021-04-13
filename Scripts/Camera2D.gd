extends Camera2D

onready var player = get_node_or_null("/root/World/Player")
onready var tween = $Tween


func _physics_process(_delta):
	position = player.position

