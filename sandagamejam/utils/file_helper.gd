# file_helper.gd
extends Node

# Puede ser usado como clase en todo el proyecto
class_name FileHelper

# Puede devolver Dictionary, Array, etc desde JSON
static func read_data_from_file(json_path: String) -> Variant:
	var file := FileAccess.open(json_path, FileAccess.READ)

	if not file:
		push_error("No se pudo abrir el archivo JSON: " + json_path)
		return null
	
	var json_text = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_text)
	if data == null:
		push_error("Error al parsear el JSON: " + json_path)

	return data
