extends Node2D

var file_location = "res://i18n/characters_moods.json"
var client_count = 4

 # Escena del nivel base
func _ready():
	var universe_combinations := get_random_combinations(file_location, client_count)
	
	for comb in universe_combinations:
		print("Personaje: ", comb["character_id"], "\nEstado: ", comb["mood_id"], "\nTexto: ", comb["texts"][GlobalManager.game_language])
		print("......")
	print("NIVEL 1 CARGADO")

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
