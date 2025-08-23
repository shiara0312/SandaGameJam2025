extends Control


func _on_close_button_pressed() -> void:
	var menu_scene = load("res://MainScene.tscn")
	get_tree().change_scene_to_packed(menu_scene)
