extends Control


func _on_close_button_pressed() -> void:
	var menu_scene = load("res://scenes/menus/MainMenu.tscn")
	get_tree().change_scene_to_packed(menu_scene)
