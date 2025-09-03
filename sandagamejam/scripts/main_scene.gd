extends Control

@onready var btn_jugar : Area2D = $Jugar
@onready var btn_creditos : Area2D = $Creditos
@onready var btn_opciones : Area2D = $Opciones
@onready var btn_salir : TextureButton = $Salir

func _ready():
	set_button_labels()
	var cursor_texture = preload("res://assets/UI/hand_point.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16))
	
	# Conectar al cambio de idioma
	if GlobalManager.has_signal("language_changed"):
		GlobalManager.language_changed.connect(_on_language_changed)

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
		var lang : String = GlobalManager.game_language
		if data.has(lang):
			var labels = data[lang]
			# Asignar a los botones
			btn_jugar.get_node("CollisionPolygon2D/Label").text = labels["jugar"]
			btn_opciones.get_node("CollisionPolygon2D/Label").text = labels["opciones"]
			btn_creditos.get_node("CollisionPolygon2D/Label").text = labels["creditos"]
			btn_salir.get_node("Label").text = labels["salir"]
		else:
			push_error("Idioma no encontrado en JSON: " + lang)
	else:
		push_error("No se pudo abrir el archivo JSON.")

func _on_language_changed() -> void:
	# Cuando GlobalManager emite la señal, refrescar etiquetas
	set_button_labels()

func _on_jugar_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		AudioManager.play_click_sfx()
		var level_1_path = "res://scenes/levels/PastryLevel1.tscn"
		GlobalManager.start_game()
		GameController.load_level(level_1_path)
		GameController.show_newton_layer()
		queue_free()
		
func _on_creditos_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		AudioManager.play_click_sfx()
		var credits_scene = load("res://scenes/menus/Credits.tscn")
		get_tree().change_scene_to_packed(credits_scene)

func _on_opciones_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		AudioManager.play_click_sfx()

		var modal = load("res://OpcionesModal.tscn").instantiate()
		GameController.current_scene_container.add_child(modal)


func _on_salir_pressed() :
	get_tree().quit()

func _on_button_mouse_entered():
	var hand_cursor = preload("res://assets/UI/hand_point.png")
	Input.set_custom_mouse_cursor(hand_cursor, Input.CURSOR_ARROW, Vector2(8, 8))
