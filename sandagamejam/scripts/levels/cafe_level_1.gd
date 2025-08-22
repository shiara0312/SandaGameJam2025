extends Control

@onready var characters = $Personajes
@onready var customer_scene := preload("res://scenes/Cliente.tscn")
	
var file_location = "res://i18n/characters_moods.json"
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
	print("original_viewport_size-> ", original_viewport_size)
	# detecta cambios de tamaño de ventana
	#get_viewport().connect("size_changed", Callable(self, "_on_resize"))

	# Cargar combinaciones y preparar cola
	var universe_combinations := get_random_combinations(file_location, customer_count)
	GlobalManager.initialize_customers(universe_combinations)
	
	spawn_next_customer()
	#print_combos(universe_combinations) # for debug
	print("NIVEL 1 CARGADO") # for debug

func spawn_next_customer():
	var next := GlobalManager.get_next_customer()
	if next.is_empty():
		# TODO: posible victoria
		print("Todos fueron atendidos")
		return 
	
	current_customer = customer_scene.instantiate()
	current_customer.setup(next, GlobalManager.game_language)
	characters.add_child(current_customer)
	
	# Posición inicial (fuera de pantalla, izquierda)
	current_customer.position = Vector2(-200, get_viewport().size.y / 2)
	
	# Calcular target X centrado tomando en cuenta el ancho del sprite
	var viewport_width = get_viewport().size.x
	var sprite_width = current_customer.sprite.texture.get_size().x * current_customer.sprite.scale.x
	# Destino = centro horizontal considerando el ancho del sprite
	var target_x = (viewport_width / 2)
	var target_position = Vector2(target_x, get_viewport().size.y / 2) # 400
	print("viewport_width ", viewport_width, "sprite width ", sprite_width)
	print("target x", target_x)
	#1000 200  -> 500 - 100 
	#400 + 200 + 400
	current_customer.move_to(target_position)
	
	# Guardar la posición relativa para resize
	current_customer.relative_x = target_x / viewport_width

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

func _move_customer_to_center():
	if not current_customer:
		return
	var screen_size = get_viewport().size
	print("screen size ", screen_size)
	var target = Vector2(screen_size.x * center_frac_x, screen_size.y / 2)
	current_customer.move_to(target)
	
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
	
