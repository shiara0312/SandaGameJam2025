extends Node

@onready var current_scene_container = $CurrentScene
@onready var ui_overlay = $UIOverlay

var current_level: Node = null
	
func load_level(level_path: String) -> void:
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
		

	
	var scene = load(level_path)
	if not scene:
		push_error("No se encontró la escena: " + level_path)
		return
	
	current_level = scene.instantiate()
	get_tree().root.add_child(current_level)
	get_tree().current_scene = current_level
	
func show_minigame(path: String):
	var minigame = load(path).instantiate()
	ui_overlay.add_child(minigame)

func hide_minigames():
	free_children(ui_overlay)

func free_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()
