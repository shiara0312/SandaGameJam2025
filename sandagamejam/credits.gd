extends Control

@onready var credits_theme: Theme = preload("res://custom_resources/Credits.tres")


func _ready():
	self.theme = credits_theme

	var grid = GridContainer.new()
	grid.columns = 2
	grid.anchor_left = 0.5
	grid.anchor_right = 0.5
	grid.anchor_top = 0.5
	grid.anchor_bottom = 0.5
	grid.grow_horizontal = Control.GROW_DIRECTION_BOTH
	grid.grow_vertical = Control.GROW_DIRECTION_BOTH
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(grid)

	# Créditos
	_add_credit(grid, "Melissa Huerta", "Game Developer & Tech Designer")
	_add_credit(grid, "Shiara Arauzo", "Game Developer")
	_add_credit(grid, "Malu Munayco", "Game Developer")
	_add_credit(grid, "Selene Negrón", "Concept Artist & 2D Artist")
	_add_credit(grid, "Ariadna Mestanza", "Concept Artist & 2D Artist")
	_add_credit(grid, "Fabrizio Murguia", "Game Designer")

func _add_credit(grid: GridContainer, member: String, role: String):
	var name_label = Label.new()
	name_label.text = member
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	var role_label = Label.new()
	role_label.text = role
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	grid.add_child(name_label)
	grid.add_child(role_label)


func _on_close_button_pressed() -> void:
	var menu_scene = load("res://scenes/menus/MainMenu.tscn")
	get_tree().change_scene_to_packed(menu_scene)
