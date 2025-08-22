extends Control

var file_location = "res://i18n/characters_moods.json"
var client_count = 4

# TODO: Animaciones de Newton: idle, feliz, trsite.
# TODO: ClientesContainer generar los personajes de forma dinamica Cliente.tscn
# TODO: UI Layer Elementos: tiempo, puntuación, pedidos correctos/fallidos.


# Escena del nivel base
func _ready():
	var universe_combinations := get_random_combinations(file_location, client_count)



	for comb in universe_combinations:
		print("Personaje: ", comb["character_id"], "\nEstado: ", comb["mood_id"], "\nTexto: ", comb["texts"][GlobalManager.game_language])
		print("......")
	print("NIVEL 1 CARGADO")

func instance_ui():
	# TODO: Instanciar la escena UI y agregarla a UILayer.
	# Mostrar los 3 corazones y el temporizador (3 min → countdown).
	pass
	

func get_random_combinations(json_path: String, count: int = 4) -> Array:
	var file := FileAccess.open(json_path, FileAccess.READ)

	if not file:
		push_error("No se pudo abrir el archivo JSON: " + json_path)
		return []
	
	var json_text = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_text)
	if typeof(data) != TYPE_DICTIONARY: #27
		push_error("El JSON no es un Dictionary válido")
		return []
	
	if not data.has("combinations"):
		push_error("El JSON no tiene la sección 'combinations'")
		return []
		
	# Clonar data, para no modificar el original, y mezclar
	var combos = data["combinations"].duplicate()
	combos.shuffle()

	# Tomar las primeras `count` combinaciones
	var selected : Array = combos.slice(0, min(count, combos.size()))
	return selected


# Cargar sprites
	# Cuando entra un personaje, se instancia dentro de Characters.
	# Queda detrás de la barra y delante del fondo.

#Cuando el jugador clickea en "¿qué le pasa?"

#Se instancia el Minigame dentro de MinigameLayer.

#El minijuego ocupa la mitad de la pantalla (puede usar un Control con anchors para centrarse).

#N#ewton se mantiene adelante (no lo tapa el minijuego).

#Al terminar el minijuego

#El Minijuego instanciado se elimina de MinigameLayer.

#El personaje resuelve su estado.
