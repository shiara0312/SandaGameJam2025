extends Node

var is_game_started : bool = false
var game_language : String = "es" # pueden ser "en", "fr".
var clientes_por_atender: Array = []
var clientes_satisfechos: Array = []

func start_game():
	is_game_started = true

# Clonar los clientes obtenidos para el nivel 
func inicializar_clientes(combos: Array):
	clientes_por_atender = combos.duplicate()

func obtener_siguiente_cliente() -> Dictionary:
	if clientes_por_atender.is_empty():
		return {}
	# retorna el primer elemento del array
	return clientes_por_atender.pop_front()

func devolver_cliente(cliente: Dictionary):
	clientes_por_atender.append(cliente)

func marcar_como_satisfecho(cliente: Dictionary):
	clientes_satisfechos.append(cliente)
