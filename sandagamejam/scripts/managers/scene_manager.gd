extends Node

func change_scene(scene_path: String) -> void:
	var scene = load(scene_path)
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		push_error("No se pudo cargar la escena: " + scene_path)
