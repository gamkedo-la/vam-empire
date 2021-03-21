extends Node

# Built largely by following the doc: https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html#global-gd
var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
func goto_scene(path):
	# Defer the load until the current scene is done executing code
	call_deferred("deferred_goto_scene", path)


func _deferred_goto_scene(path):
	
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.Instance()
	
	get_tree().get_root().add_child(current_scene)
	
	get_tree().set_current_scene(current_scene)
