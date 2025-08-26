extends Node2D

@onready var characters = $Personajes
@onready var customer_scene := preload("res://scenes/characters/Customer.tscn")
@onready var PauseBtn = $PauseBtn
@export var pause_texture: Texture

var characters_mood_file_path = "res://i18n/characters_moods.json"
var interact_btns_file_path = "res://i18n/interaction_texts.json"
var customer_count = 3 # TODO: update
var current_customer: Node2D = null

var center_frac_x := 0.5 # 0.25 cuando se abra el minijuego
var original_viewport_size: Vector2

# TODO: UI Layer Elementos: tiempo, puntuación, pedidos correctos/fallidos.

# Escena del nivel base
func _ready():
	original_viewport_size = get_viewport().size
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
	PauseBtn.connect("pressed", Callable(self, "_on_pause_pressed"))
	# Cargar combinaciones y preparar cola
	var universe_combinations := get_random_combinations(characters_mood_file_path, customer_count)
	GlobalManager.initialize_customers(universe_combinations)
	spawn_next_customer()
	
	GlobalManager.initialize_recipes("level1")


func spawn_next_customer():
	print("DEBUG > spawn_next_customer")
	var next := GlobalManager.get_next_customer()
	if next.is_empty():
		# TODO: posible victoria
		print("Todos fueron atendidos y son felices")
		return 
	
	current_customer = customer_scene.instantiate()
	current_customer.setup(next, GlobalManager.game_language)
	characters.add_child(current_customer)
	
	# Conectar señales
	current_customer.arrived_at_center.connect(_on_customer_seated)
	current_customer.connect("listen_customer_pressed", Callable(self, "_on_listen_customer_pressed"))

	# Estado del cliente
	current_customer.set_state(current_customer.State.ENTERING)	
	
	# Esperar el frame cuando se hace resize 
	await get_tree().process_frame
	
	# Calcular posiciones usando helpers del customer
	var viewport_size = get_viewport().size
	var start_pos = current_customer.get_initial_position()
	var target_pos = current_customer.get_target_position()
	current_customer.position = start_pos
	current_customer.move_to(target_pos)
	
	# Guardar la posición relativa para resize
	#current_customer.relative_x = target_pos.x / viewport_size.x

func get_random_combinations(json_path: String, count: int = 4) -> Array:
	var customer_data = FileHelper.read_data_from_file(json_path)

	if typeof(customer_data) != TYPE_DICTIONARY: #27
		push_error("El JSON no es un Dictionary válido")
		return []
	
	if not customer_data.has("combinations"):
		push_error("El JSON no tiene la sección 'combinations'")
		return []
		
	# Clonar customer_data, para no modificar el original, y mezclar
	var combos = customer_data["combinations"].duplicate()
	combos.shuffle()

	# Tomar las primeras `count` combinaciones
	var selected : Array = combos.slice(0, min(count, combos.size()))
	return selected

# Funciones lanzadas por los signals
func _on_customer_seated(cust: Node2D):
	var btn_listen : TextureButton = cust.get_node("BtnListen")
	btn_listen.show()
	#print("DEBUG > _on_customer_seated El cliente llegó y se sentó: ", cust.character_id, "\n", cust.mood_id, "\n", cust.texts, "\n", cust.language)
	
func _on_listen_customer_pressed():
	UILayerManager.show_message(current_customer.texts[current_customer.language])
	
func _on_viewport_resized():
	if current_customer:
		var viewport_size = get_viewport().size
		var new_target = current_customer.get_target_position()

		# Mantener coherencia en X e Y
		current_customer.position.x = new_target.x
		current_customer.position.y = new_target.y
		
		#var sprite_width =  current_customer.sprite.texture.get_size().x * current_customer.sprite.scale.x
		#current_customer.position.x = (get_viewport().size.x / 2) - (sprite_width / 2)

# Debug :]
func print_combos(combos):
	for comb in combos:
		print("Personaje: ", comb["character_id"], "\nEstado: ", comb["mood_id"], "\nTexto: ", comb["texts"][GlobalManager.game_language])
		print("......")
