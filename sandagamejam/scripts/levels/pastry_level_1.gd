extends Control

@onready var characters = $Personajes
@onready var customer_scene := preload("res://scenes/Customer.tscn")
	
var characters_mood_file_path = "res://i18n/characters_moods.json"
var interact_btns_file_path = "res://i18n/interaction_texts.json"
var customer_count = 4
var current_customer: Node2D = null
var center_frac_x := 0.5 # 0.25 cuando se abra el minijuego

var customer

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

	# Cargar el sprite "ENTERING"
	current_customer.set_state(current_customer.State.ENTERING)	
	
	# Obtener el sprite del cliente
	var sprite: Sprite2D = current_customer.get_node("Sprite2D")
	var sprite_size = sprite.texture.get_size() * sprite.scale
	
	# Vista actual
	var viewport_size = get_viewport().size
	print("my sprite... ", sprite, " ", sprite_size)

	# Centrado en X, 20px arriba del borde inferior
	var start_x = viewport_size.x / 2
	var start_y = viewport_size.y - (sprite_size.y / 2 + 60)

	# Posición inicial (fuera de pantalla, izquierda)
	current_customer.position = Vector2(-200, start_y)

	# Tamaño real del sprite considerando escala
	#var sprite_width = sprite.texture.get_size().x * sprite.scale.x

	# Calcular target X centrado tomando en cuenta el ancho del sprite
	var viewport_width = get_viewport().size.x
	
	# Destino = centro horizontal considerando el ancho del sprite
	var target_x = (viewport_width / 2)
	var target_position = Vector2(target_x, start_y)
	current_customer.move_to(target_position)
	
	# Guardar la posición relativa para resize
	current_customer.relative_x = target_x / viewport_size.x

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
	var btns_data = FileHelper.read_data_from_file(interact_btns_file_path)
	if btns_data:
		print("btns.. ", btns_data[GlobalManager.game_language]["customer_seated"])
		var btn_listen : TextureButton = cust.get_node("BtnListen")
		btn_listen.get_node("Label").text = btns_data[GlobalManager.game_language]["customer_seated"]
		btn_listen.show()
	print("El cliente llegó y se sentó: ", cust.character_id, "\n", cust.mood_id, "\n", cust.texts, "\n", cust.language)
	
func _on_listen_customer_pressed():
	print("escuchando")
# TODO: Cargar sprites



#Se instancia el Minigame dentro de MinigameLayer.

#El minijuego ocupa la mitad de la pantalla (puede usar un Control con anchors para centrarse).

#N#ewton se mantiene adelante (no lo tapa el minijuego).

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
	
