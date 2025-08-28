# MinigameOverlay.tscn maneja la UI/flujo del minijuego.
extends Node2D

@onready var menu_container : Control = $TextureRect/MenuContainer
@onready var recipe_container : Control = $TextureRect/RecipeContainer
@onready var recollect_container : Control = $TextureRect/RecollectContainer
@onready var btn_prepare : TextureButton = $TextureRect/BtnPrepareRecipe

var minigame_started := false
var active_tweens := []

func _ready():
	load_menu_data()
	load_btn_labels()

func hide_menu_container():
	menu_container.visible = false

func show_menu_container():
	load_menu_data()
	menu_container.visible = true

func hide_recipe_container():
	recipe_container.visible = false

func show_recipe_container():
	recipe_container.visible = true

func hide_recollect_container():
	recollect_container.visible = false

func show_recollect_container():
	recollect_container.visible = true

func show_selected_recipe(idx: int) -> void:
	GlobalManager.selected_recipe_idx = idx
	load_selected_recipe_data(idx)
	load_ingredients_assets()
	hide_menu_container()
	show_recipe_container()

func load_menu_data() -> void:
	var recipe_buttons = [
		menu_container.get_node("Recipe1"),
		menu_container.get_node("Recipe2"),
		menu_container.get_node("Recipe3"),
		menu_container.get_node("Recipe4")
	]
	
	for i in range(GlobalManager.current_level_recipes.size()):
		var recipe_data = GlobalManager.current_level_recipes[i]
		var recipe_id = recipe_data["id"]
		var path = "res://assets/pastry/recipes/%s.png" % recipe_id
		if not ResourceLoader.exists(path):
			print("⚠️ No existe asset:", path)
			continue
		
		var tex = load(path)
		if i < recipe_buttons.size():
			var button = recipe_buttons[i]
			var sprite = button.get_node("Sprite2D") 
			if sprite:
				sprite.texture = tex
		
func load_btn_labels() -> void:
	var continue_label = recipe_container.get_node("BtnContinue/Label")
	var back_label = recipe_container.get_node("BtnBack/Label")
	var cook_label = btn_prepare.get_node("Label")
	continue_label.text = GlobalManager.btn_choose_recipe_label
	back_label.text = GlobalManager.btn_reject_recipe_label
	cook_label.text = GlobalManager.btn_cook_recipe_label
	
func load_selected_recipe_data(idx: int) -> void:
	var lang = GlobalManager.game_language
	#print("current_level_recipes ", GlobalManager.current_level_recipes)
	var recipe_selected = GlobalManager.current_level_recipes[idx]
	var rec_name = recipe_selected["name"][lang]
	#var benefits = recipe_selected["benefits"][lang]
	var riddle = recipe_selected["riddle"][lang]
	
	#print("recipe_selected ", recipe_selected["ingredients"])
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
		var wrapper = create_ingredient_wrapper(ing_id)
		ing_container.add_child(wrapper)

func start_ingredient_minigame():
	minigame_started = true
	var recipe_selected = GlobalManager.current_level_recipes[GlobalManager.selected_recipe_idx]
	var ingredients = recipe_selected["ingredients"]
	var ingr_loop = generate_arr(ingredients, 20)
	animate_ingredients(ingr_loop)
	btn_prepare.visible = true

func animate_ingredients(ingr_loop: Array) -> void:
	#print("EMPEZAR A RECOLECTAR INGREDIENTES!!! ", ingr_loop)
	var container := recollect_container
	clear_children(container)

	var start_x := recollect_container.position.x + recollect_container.size.x + 100
	var end_x := recollect_container.position.x
	var spacing := 200
	var duration := 4.0
	var y := 100
	var spawn_interval := 1.0  # tiempo entre aparición de cada ingrediente

	for i in range(ingr_loop.size()):
		var ing_id = ingr_loop[i]
		var wrapper = create_ingredient_wrapper(ing_id, true)
		container.add_child(wrapper)

		wrapper.position = Vector2(start_x + (i * spacing), y)

		var tween := create_tween()
		tween.tween_property(wrapper, "position:x", end_x, duration + spawn_interval * i)\
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_delay(spawn_interval * i)
		tween.tween_callback(Callable(wrapper, "queue_free"))
		# Guardar tween para poder cancelarlo
		active_tweens.append(tween)
	
	if GlobalManager.collected_ingredients.size() > 1:
		print("ya cogiste mas de 1")

	
func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
		
func create_ingredient_wrapper(ingredient_id: String, is_clickable: bool = false):
	var path = "res://assets/pastry/ingredients/%s.png" % ingredient_id
	if not ResourceLoader.exists(path):
		print("⚠️ No existe asset:", path)

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
	
	if is_clickable:
		sprite.mouse_filter = Control.MOUSE_FILTER_STOP
		sprite.connect("gui_input", Callable(self, "_on_ingredient_clicked").bind(wrapper, ingredient_id))

	wrapper.add_child(sprite)
	return wrapper

# Helpers
func generate_arr(base: Array, base_len: int) -> Array:
	# Generar un array con ingredientes variados que contengan por lo menos una vez cada ingrediente
	var result = []
	result = base.duplicate()
	
	while result.size() < base_len:
		var rand = base[randi() % base.size()]
		result.append(rand)
	
	shuffle_array(result)
	
	return result

func shuffle_array(arr: Array) -> void:
	# starts at arr.size() -1, ends in 0
	for i in range(arr.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp

# Botones
func _on_recipe_1_pressed() -> void:
	AudioManager.play_click_sfx()
	show_selected_recipe(0)

func _on_recipe_2_pressed() -> void:
	AudioManager.play_click_sfx()
	show_selected_recipe(1)

func _on_recipe_3_pressed() -> void:
	AudioManager.play_click_sfx()
	show_selected_recipe(2)

func _on_recipe_4_pressed() -> void:
	AudioManager.play_click_sfx()
	show_selected_recipe(3)

func _on_btn_back_pressed() -> void:
	AudioManager.play_click_sfx()
	hide_recipe_container()
	show_menu_container()

func _on_btn_continue_pressed() -> void:
	AudioManager.play_click_sfx()
	hide_recipe_container()
	hide_menu_container()
	show_recollect_container()
	start_ingredient_minigame()
	
func _on_btn_prepare_recipe_pressed() -> void:
	AudioManager.play_click_sfx()
	if minigame_started:
		 # Cancelar todos los tweens activos
		for t in active_tweens:
			if is_instance_valid(t):
				t.kill()
		active_tweens.clear()
		
		# Limpiar ingredientes que aún no se recogieron
		clear_children(recollect_container)
		
		minigame_started = false
		btn_prepare.visible = false
		GameController.make_newton_cook()

func _on_ingredient_clicked(event: InputEvent, wrapper: Control, ing_id: String):
	if event is InputEventMouseButton and event.pressed:
		AudioManager.play_collect_ingredient_sfx()
		
		# mover ingrediente al centro
		var target_pos = Vector2(550, recollect_container.position.y + recollect_container.size.y - 50)
		var tween = create_tween()
		tween.tween_property(wrapper, "position", target_pos, 0.5)\
			.set_trans(Tween.TRANS_LINEAR)\
			.set_ease(Tween.EASE_IN)
		tween.tween_callback(Callable(wrapper, "queue_free"))
		
		GlobalManager.collected_ingredients.append(ing_id)
		
		#print("🍎 Ingredient recolectado:", ing_id)
		
		if GlobalManager.collected_ingredients.size() >= 1 and is_instance_valid(btn_prepare):
			btn_prepare.visible = true
			btn_prepare.disabled = false
