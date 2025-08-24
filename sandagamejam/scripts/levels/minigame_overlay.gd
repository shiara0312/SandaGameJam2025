# MinigameOverlay.tscn
extends Node2D

@onready var menu_container : Control = $TextureRect/MenuContainer
@onready var recipe_container : Control = $TextureRect/RecipeContainer

func _ready():
	# TODO: cargar sprites de recetas segun el nivel 
	print("ready >> ")
	#print("ready >> , GlobalManager.ingredients)
	#print("ready >> ", GlobalManager.current_level_recipes)

func hide_menu_container():
	menu_container.visible = false

func show_menu_container():
	menu_container.visible = true

func hide_recipe_container():
	recipe_container.visible = false

func show_recipe_container():
	recipe_container.visible = true

func show_selected_recipe(idx: int) -> void:
	load_selected_recipe_data(idx)
	hide_menu_container()
	show_recipe_container()

func load_selected_recipe_data(idx: int) -> void:
	var lang = GlobalManager.game_language
	var recipe_selected = GlobalManager.current_level_recipes[idx]
	var rec_name = recipe_selected["name"][lang]
	var benefits = recipe_selected["benefits"][lang]
	var riddle = recipe_selected["riddle"][lang]
	
	print("recipe_selected ", recipe_selected["ingredients"])
	
	var text = "[center][font_size=35]" + rec_name + "[/font_size][/center]\n\n"
	text += "[font_size=36] " + riddle + "[/font_size]"

	var rich_label_text = recipe_container.get_node("RichTextLabel")
	rich_label_text.bbcode_enabled = true
	rich_label_text.text = text
	
func _on_recipe_1_pressed() -> void:
	show_selected_recipe(0)

func _on_recipe_2_pressed() -> void:
	show_selected_recipe(1)

func _on_recipe_3_pressed() -> void:
	show_selected_recipe(2)

func _on_recipe_4_pressed() -> void:
	show_selected_recipe(3)

func _on_btn_back_pressed() -> void:
	hide_recipe_container()
	show_menu_container()

func _on_btn_continue_pressed() -> void:
	hide_recipe_container()
	hide_menu_container()
	print("EMPEZAR A RECOLECTAR INGREDIENTES!!!")
