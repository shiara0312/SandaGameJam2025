extends Node

var is_game_started : bool = false
var game_language : String = "es" # pueden ser "en", "fr".
var customers_to_serve: Array = []
var satisfied_customers: Array = []



func start_game():
	is_game_started = true

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
