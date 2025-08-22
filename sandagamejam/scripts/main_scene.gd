extends Control

@onready var btn_jugar : Area2D = $Jugar

@onready var btn_opciones : TextureButton = $Opciones
@onready var btn_creditos : TextureButton = $Creditos
@onready var btn_salir : TextureButton = $Salir

func _ready():
	set_button_labels()

# TODO: Cuando se elige un idioma, llamar set_button_labels

func set_button_labels() -> void:	
	# Seteando labels segun el idioma
	#print("Seteando labels para idioma:", GlobalManager.game_language)
	# Cargar el JSON
	var file := FileAccess.open("res://i18n/menu_labels.json", FileAccess.READ)
	
	if file:
		var json_text := file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(json_text)
		if data == null:
			push_error("Error al parsear el JSON de menu labels.")
			return
		
		# Buscar las traducciones del idioma actual
		var lang := GlobalManager.game_language
		if data.has(lang):
			var labels = data[lang]
			# Asignar a los botones
			btn_jugar.get_node("CollisionPolygon2D/Label").text = labels["jugar"]
			btn_opciones.get_node("Label").text = labels["opciones"]
			btn_creditos.get_node("Label").text = labels["creditos"]
			btn_salir.get_node("Label").text = labels["salir"]
		else:
			push_error("Idioma no encontrado en JSON: " + lang)
	else:
		push_error("No se pudo abrir el archivo JSON.")

func _on_opciones_pressed() -> void:
	print("OPCIONES fue presionado")

func _on_creditos_pressed() -> void:
	print("CREDITOS fue presionado")

func _on_salir_pressed() -> void:
	print("SALIR fue presionado")


func _on_jugar_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		GlobalManager.start_game()
		get_tree().change_scene_to_file("res://scenes/levels/PastryLevel1.tscn")
