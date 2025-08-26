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

var game_language : String = "es" 
var customers_to_serve: Array = []
var satisfied_customers: Array = []
var current_level_recipes: Array = []
var ingredients: Array = []
var selected_recipe_idx : int = 0


var btn_listen_customer_label = ""
var btn_help_customer_label = ""
var btn_reject_recipe_label = ""
var btn_choose_recipe_label = ""

var interaction_texts := {}     
var menu_labels := {}        
var characters_moods := {}    

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
	if interaction_texts == {}:
		interaction_texts = _cargar_json_file("res://i18n/interaction_texts.json")
	if menu_labels == {}:
		menu_labels = _cargar_json_file("res://i18n/menu_labels.json")
	if characters_moods == {}:
		characters_moods = _cargar_json_file("res://i18n/characters_moods.json")
	
	if game_language in interaction_texts:
		btn_listen_customer_label = interaction_texts[game_language]["customer_seated"]
		btn_help_customer_label = interaction_texts[game_language]["start_helping"]
		btn_reject_recipe_label = interaction_texts[game_language]["reject_recipe"]
		btn_choose_recipe_label = interaction_texts[game_language]["choose_recipe"]
	else:
		btn_listen_customer_label = "Customer"
		btn_help_customer_label = "Help"


func _cargar_json_file(path: String) -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		push_error("No se pudo abrir " + path)
		return {}
	var text = f.get_as_text()
	f.close()
	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		return data
	else:
		push_error("Error parseando JSON: " + path)
		return {}

func cambiar_idioma(nuevo_idioma: String) -> void:
	game_language = nuevo_idioma
	load_button_labels()
