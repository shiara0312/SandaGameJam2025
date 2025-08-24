extends Control

@onready var characters = $Personajes
@onready var customer_scene := preload("res://scenes/Customer.tscn")
	
var characters_mood_file_path = "res://i18n/characters_moods.json"
var interact_btns_file_path = "res://i18n/interaction_texts.json"
var customer_count = 4
var current_customer: Node2D = null

var center_frac_x := 0.5 # 0.25 cuando se abra el minijuego
var original_viewport_size: Vector2

# TODO: Animaciones de Newton: idle, feliz, trsite.
# TODO: ClientesContainer generar los personajes de forma dinamica Cliente.tscn
# TODO: UI Layer Elementos: tiempo, puntuación, pedidos correctos/fallidos.


# Escena del nivel base
func _ready():
	original_viewport_size = get_viewport().size
	
	# Cargar combinaciones y preparar cola
	var universe_combinations := get_random_combinations(characters_mood_file_path, customer_count)
	GlobalManager.initialize_customers(universe_combinations)
	
	spawn_next_customer()

func spawn_next_customer():
	var next := GlobalManager.get_next_customer()
	if next.is_empty():
		# TODO: posible victoria
		print("Todos fueron atendidos y son felices")
		return 
	
	current_customer = customer_scene.instantiate()
	current_customer.setup(next, GlobalManager.game_language)
	characters.add_child(current_customer)
	
	# Conectar señal cuando cliente llegue al centro
	current_customer.arrived_at_center.connect(_on_customer_seated)
	current_customer.connect("listen_customer_pressed", Callable(self, "_on_listen_customer_pressed"))

	# Posicionar y mover
	current_customer.set_state(current_customer.State.ENTERING)	
	# Calcular posiciones usando helpers del customer
	var viewport_size = get_viewport().size
	var start_pos = current_customer.get_initial_position(viewport_size)
	var target_pos = current_customer.get_target_position(viewport_size)
	current_customer.position = start_pos
	current_customer.move_to(target_pos)
	
	# Guardar la posición relativa para resize
	current_customer.relative_x = target_pos.x / viewport_size.x

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

	print("El cliente llegó y se sentó: ", cust.character_id, "\n", cust.mood_id, "\n", cust.texts, "\n", cust.language)
	
func _on_listen_customer_pressed():
	UILayerManager.show_message(current_customer.texts[current_customer.language])

#TODO: Instanciar el Minigame dentro de MinigameLayer.
	#El minijuego ocupa la mitad de la pantalla (puede usar un Control con anchors para centrarse).
	#Newton se mantiene adelante (no lo tapa el minijuego).
	#Al terminar el minijuego
	#El Minijuego instanciado se elimina de MinigameLayer.
	#El personaje resuelve su estado.
	# Nueva posición proporcional considerando el sprite
	
func _on_viewport_resized():
	if current_customer:
		var sprite_width =  current_customer.sprite.texture.get_size().x * current_customer.sprite.scale.x
		current_customer.position.x = (get_viewport().size.x / 2) - (sprite_width / 2)

# Debug :]
func print_combos(combos):
	for comb in combos:
		print("Personaje: ", comb["character_id"], "\nEstado: ", comb["mood_id"], "\nTexto: ", comb["texts"][GlobalManager.game_language])
		print("......")
	
