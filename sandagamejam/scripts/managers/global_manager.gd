# GlobalManager
extends Node

signal lives_changed(new_lives)
signal time_changed(new_time)
signal time_up
signal game_over

var lives = 3
var time_left : float = 180.0
var is_game_running : bool = false
var is_paused: bool = false
var is_minigame_overlay_visible : bool = false

var game_language : String = "es" # pueden ser "en", "fr".
var customers_to_serve: Array = []
var satisfied_customers: Array = []
var current_level_recipes: Array = []
var ingredients: Array = []

#Interacciones
var btn_listen_customer_label = ""
var btn_help_customer_label = ""

func start_game():
	print("GAME HAS STARTED")
	is_game_running = true
	
	load_button_labels()
	UILayerManager.init_ui_layer()
	UILayerManager.show_hud()

#### Gestionar tiempo y vidas ####
func _process(delta: float) -> void:
	if is_game_running and not is_paused:
		time_left -= delta
		emit_signal("time_changed", time_left)
		if time_left <= 0:
			time_left = 0
			is_game_running = false
			emit_signal("time_up")


# TODO: Quitar 10 segundos GloblManager.apply_penalty(10)
func apply_penalty(seconds: float):
	time_left = max(time_left - seconds, 0)
	emit_signal("time_changed", time_left)
	
	if time_left == 0 and is_game_running:
		is_game_running = false
		emit_signal("time_up")

func lose_life():
	if lives > 0:
		lives -= 1
		emit_signal("lives_changed", lives)
		if lives == 0:
			emit_signal("game_over")
			
#### Gestionar cola de clientes ####
func initialize_customers(combos: Array):
	# Clonar los clientes obtenidos para el nivel 
	customers_to_serve = combos.duplicate()

func get_next_customer() -> Dictionary:
	if customers_to_serve.is_empty():
		return {}
	# retorna el primer elemento del array
	return customers_to_serve.pop_front()

func return_customer(customer: Dictionary):
	customers_to_serve.append(customer)

func mark_customer_as_satisfied(customer: Dictionary):
	satisfied_customers.append(customer)

### Gestionar recetas ###
func initialize_recipes(level: String):
	var level_recipes_json_path = "res://i18n/levels_recipes.json"
	var all_recipes_json_path = "res://i18n/all_recipes.json"
	var ingredients_json_path = "res://i18n/ingredients.json"
	var level_recipe_ids = FileHelper.read_data_from_file(level_recipes_json_path)[level]
	var all_recipes = FileHelper.read_data_from_file(all_recipes_json_path)
	ingredients = FileHelper.read_data_from_file(ingredients_json_path)

	for recipe in all_recipes:
		if recipe["id"] in level_recipe_ids:
			current_level_recipes.append(recipe)

### Game Controls ###
func pause_game():
	is_paused = true
	is_game_running = false

func resume_game():
	is_paused = false
	is_game_running = true

### Botones de interaccion con el cliente ###
func load_button_labels():
	var interact_btns_file_path = "res://i18n/interaction_texts.json"
	
	var btns_data = FileHelper.read_data_from_file(interact_btns_file_path)
	btn_listen_customer_label = btns_data[game_language]["customer_seated"]
	btn_help_customer_label = btns_data[game_language]["start_helping"]
