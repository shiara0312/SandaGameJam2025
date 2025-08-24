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
	GlobalManager.selected_recipe_idx = idx
	load_selected_recipe_data(idx)
	load_ingredients_assets()
	hide_menu_container()
	show_recipe_container()

func load_selected_recipe_data(idx: int) -> void:
	var lang = GlobalManager.game_language
	print("current_level_recipes ", GlobalManager.current_level_recipes)
	var recipe_selected = GlobalManager.current_level_recipes[idx]
	var rec_name = recipe_selected["name"][lang]
	#var benefits = recipe_selected["benefits"][lang]
	var riddle = recipe_selected["riddle"][lang]
	
	print("recipe_selected ", recipe_selected["ingredients"])
	
	var text = "[center][font_size=35]" + rec_name + "[/font_size][/center]\n\n"
	text += "[font_size=36] " + riddle + "[/font_size]"

	var rich_label_text = recipe_container.get_node("RichTextLabel")
	rich_label_text.bbcode_enabled = true
	rich_label_text.text = text
	
func load_ingredients_assets():
	var recipe_selected = GlobalManager.current_level_recipes[GlobalManager.selected_recipe_idx]
	var ingredients = recipe_selected["ingredients"]

	# Contenedor donde irán los ingredientes
	var ing_container = recipe_container.get_node("IngredientsContainer")
	clear_children(ing_container)


	for i in range(ingredients.size()):
		var ing_id = ingredients[i]
		var path = "res://assets/pastry/ingredients/%s.png" % ing_id
		if not ResourceLoader.exists(path):
			print("⚠️ No existe asset:", path)
			continue

		var tex = load(path)
		
		# Wrapper (para escalarlo)
		var wrapper = Control.new()
		wrapper.custom_minimum_size = tex.get_size() * 0.25
		wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		var sprite = TextureRect.new()
		sprite.texture = tex
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.anchor_right = 1
		sprite.anchor_bottom = 1
		sprite.size_flags_horizontal = Control.SIZE_FILL
		sprite.size_flags_vertical = Control.SIZE_FILL

		wrapper.add_child(sprite)
		ing_container.add_child(wrapper)

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

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
