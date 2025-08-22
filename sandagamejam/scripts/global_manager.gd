extends Node

var lives = 3
var time_in_min = 3
var is_game_started : bool = false
var game_language : String = "es" # pueden ser "en", "fr".
var customers_to_serve: Array = []
var satisfied_customers: Array = []

func _ready():
	pass

func start_game():
	print("GAME HAS STARTED")
	is_game_started = true
	
	# Instanciamos UILayer solo después de cambiar a la escena de juego
	_init_ui_after_scene_change()

func _init_ui_after_scene_change():
	var ui_layer_scene = preload("res://scenes/ui/UILayer.tscn")
	var ui_layer_instance = ui_layer_scene.instantiate()
	get_tree().root.call_deferred("add_child", ui_layer_instance)
	ui_layer_instance.show_hud()

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
