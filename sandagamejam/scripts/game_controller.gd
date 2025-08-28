#GameController.tscn maneja Newton, los niveles y el minigame overlay.
extends Node

@onready var current_scene_container: Node2D = $CurrentSceneContainer
@onready var minigame_overlay = $MiniGameOverlay
@onready var newton_layer = $NewtonLayer
@onready var newton_ready_sprite: Sprite2D = $NewtonLayer/NewtonReadySprite
@onready var newton_moods_sprite: Sprite2D = $NewtonLayer/NewtonMoodsSprite
@onready var feedback_message: RichTextLabel = $NewtonLayer/FeedbackMessage
@onready var continue_button: TextureButton = $NewtonLayer/ContinueBtn
@onready var overlay_layer = $OverlayLayer
var final_screen: Node = null

const SCREEN_WIDTH = 1152.0
const SECONDS_TO_LOSE = 30
const SECONDS_TO_GAIN = 15
	
var is_success: bool = false
var current_level: Node = null
var current_minigame: Node = null
var newton_original_scale: Vector2 = Vector2(0.22, 0.22)
var newton_original_pos: Vector2 = Vector2(978.0, 472)

func _ready():
	newton_layer.visible = false
	GlobalManager.connect("time_up", Callable(self, "_on_time_up"))
	GlobalManager.connect("game_over", Callable(self, "_on_game_over"))
	GlobalManager.connect("win", Callable(self, "_on_win"))

func show_newton_layer():
	newton_layer.visible = true
	
# Cargar Main Menu: Jugar, Opciones, Creditos
func load_main_menu():
	# Limpiar cualquier escena previa
	free_children(current_scene_container)
	
	# Instanciar MainMenu
	var main_menu = load("res://scenes/menus/MainMenu.tscn").instantiate()
	current_scene_container.add_child(main_menu)
	AudioManager.play_game_music()
	
	# Ajustar tamaño y posición si es Control
	if main_menu is Control:
		main_menu.position = Vector2.ZERO

		newton_layer.visible = false
		pass
	
# Cargar cualquier nivel
func load_level(level_path: String) -> void:
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
	
	var scene = load(level_path)
	if not scene:
		push_error("No se encontró la escena: " + level_path)
		return
	
	current_level = scene.instantiate()
	current_scene_container.add_child(current_level)
	
	# conectar el final del nivel
	if current_level.has_signal("level_cleared"):
		current_level.connect("level_cleared", Callable(self, "_on_level_cleared"))

func show_minigame(path: String):
	var new_scale = 0.15
	var new_scale_vector = Vector2(new_scale, new_scale)
	
	slide_minigame_overlay(path)
	slide_current_level("left")
	resize_newton_ready(new_scale_vector)
	GlobalManager.is_minigame_overlay_visible = true

func finish_minigame():
	slide_current_level("right")
	reset_newton_ready()
	
	# Si existe minigame_instance guardado, animar antes de eliminarlo
	if self.current_minigame and is_instance_valid(self.current_minigame):
		var tween = create_tween()
		tween.tween_property(self.current_minigame, "modulate:a", 0.0, 0.5)
		tween.finished.connect(_on_minigame_hidden)
	else:
		_cleanup_minigames()
	
func free_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()

# Slide Minigame Overlay
func slide_minigame_overlay(path: String):
	const TARGET_X = SCREEN_WIDTH - 700
	
	var tween = create_tween()
	
	var minigame_instance = load(path).instantiate()
	minigame_overlay.add_child(minigame_instance)
	minigame_instance.scale = Vector2(1,1)
	minigame_instance.z_index = 50
	self.current_minigame = minigame_instance

	# Posición inicial: fuera de la pantalla (derecha)
	minigame_instance.position = Vector2(SCREEN_WIDTH, 0)
	# Posición final: borde izquierdo del Node2D en la mitad de la pantalla
	var target_pos = Vector2(TARGET_X, 0)
	# Tween para entrada del overlay
	tween.tween_property(minigame_instance, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Slide Level scene
func slide_current_level(direction: String = "left", duration: float = 0.5):
	var tween = create_tween()

	var start_scene_pos = current_scene_container.position
	var offset = Vector2(SCREEN_WIDTH/4, 0)
	var target_scene_pos
	if direction == "left":
		target_scene_pos = start_scene_pos - offset
	elif direction == "right":
		target_scene_pos = start_scene_pos + offset
	else:
		push_warning("Dirección inválida: " + direction)
		return
	
	tween.tween_property(current_scene_container, "position", target_scene_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Empezar a cocinar
# print("🧑🏽‍🍳 Newton esta cocinando")
func make_newton_cook():	
	# Ocular a "newton_ready"
	newton_ready_sprite.visible = false
	#resize_newton_ready(newton_original_scale)
	newton_moods_sprite.visible = true

	AudioManager.play_whisking_sfx()
	# Hacer flip horizontal repetidamente durante 2s
	var flip_timer := Timer.new()
	flip_timer.wait_time = 0.2 # cada 0.2 segundos cambia de lado
	flip_timer.autostart = true
	flip_timer.one_shot = false
	add_child(flip_timer)

	flip_timer.timeout.connect(func():
		newton_moods_sprite.flip_h = !newton_moods_sprite.flip_h
	)
	
	# Detener animación después de 2 segundos
	var tween := get_tree().create_timer(2.0)
	tween.timeout.connect(func():
		flip_timer.stop()
		flip_timer.queue_free()
		AudioManager.stop_whisking_sfx()
		show_netown_feedback()
	)

func show_netown_feedback():
	var message = check_recipe()
	var continue_btn_label = continue_button.get_node("Label")

	feedback_message.text = message
	feedback_message.visible = true
	# Cambiar sprite según resultado
	if is_success:
		AudioManager.play_right_recipe_sfx()
		newton_moods_sprite.texture = preload("res://assets/sprites/newtown/newton_win.png")
		#print("✅ Receta preparada correctamente")
	else:
		AudioManager.play_wrong_recipe_sfx()
		newton_moods_sprite.texture = preload("res://assets/sprites/newtown/newton_fail.png")
		#print("❌ Algo salió mal en la receta")
	
	continue_btn_label.text = "Entiendo..." 
	#TODO: actualizar el texto segun corresponda 
	continue_button.visible = true

func check_recipe() -> String:
	var selected_recipe = GlobalManager.current_level_recipes[GlobalManager.selected_recipe_idx]
	var selected_recipe_ingredients = selected_recipe["ingredients"]
	var selected_recipe_mood = selected_recipe["mood"]
	var collected_ingredients = GlobalManager.collected_ingredients
	var customer_mood = GlobalManager.current_customer["mood_id"]
	
	# Selecciono receta correcta?
	var correct_recipe_selected = true if selected_recipe_mood == customer_mood else false
	#print("¿Seleccionó receta correcta?	? : ", correct_recipe_selected)
	
	# Recolectó todos los ingredientes?
	var is_exact_match = arrays_match(collected_ingredients, selected_recipe_ingredients)
	#print("¿Recolectó todos los ingredientes?: ", is_exact_match)

	is_success = correct_recipe_selected and is_exact_match
	# Determinar respuesta y reglas
	var response_type
	if not correct_recipe_selected:
		response_type = GlobalManager.ResponseType.WRONG_RECIPE
		GlobalManager.lose_life()
	elif not is_exact_match:
		response_type = GlobalManager.ResponseType.WRONG_INGREDIENTS
		GlobalManager.apply_penalty(SECONDS_TO_LOSE)
	elif is_success:
		response_type = GlobalManager.ResponseType.RIGHT_RECIPE_AND_INGREDIENTS
		GlobalManager.apply_penalty(-SECONDS_TO_GAIN)
	else:
		response_type = GlobalManager.ResponseType.GRAVITATIONAL_RECIPE 

	var message = GlobalManager.get_response_text(response_type)

	return message

func reset_newton_ready() -> void:
	# Restaurar Newton
	newton_moods_sprite.texture = preload("res://assets/sprites/newtown/newton_cocinando.png")
	newton_ready_sprite.visible = true
	newton_moods_sprite.visible = false
	
	var tween = create_tween()
	tween.tween_property(newton_ready_sprite, "position", newton_original_pos, 0.5)
	tween.tween_property(newton_ready_sprite, "scale", newton_original_scale, 0.5)
	
func resize_newton_ready(new_scale_vector: Vector2) -> void:
	var tween = create_tween()
	
	# Escalar con animación
	tween.tween_property(newton_ready_sprite, "scale", new_scale_vector, 0.5)
	
	# Mover con animación (20px más abajo/derecha de su posición actual)
	var new_pos = newton_ready_sprite.position + Vector2(84,100)
	tween.tween_property(newton_ready_sprite, "position", new_pos, 0.5)

func arrays_match(collected: Array, recipe: Array) -> bool:
	# Convertir recipe a un set (diccionario)
	var recipe_set := {}
	for item in recipe:
		recipe_set[item] = true
	
	for item in collected:
		if not recipe_set.has(item):
			return false
	
	# Todos los de la receta están en collected
	for item in recipe:
		if not collected.has(item):
			return false
	
	return true

func _on_minigame_hidden():
	if self.current_minigame and is_instance_valid(self.current_minigame):
		self.current_minigame.queue_free()
		self.current_minigame = null
	
	_cleanup_minigames()
	
func _on_continue_btn_pressed() -> void:
	feedback_message.visible = false
	continue_button.visible = false
	
	# Restaurar Newton
	reset_newton_ready()
	# Ocultar minijuegos
	finish_minigame()
	# Avisar al nivel que muestre reacción del cliente
	get_tree().call_group("levels", "show_customer_reaction", is_success)

func _cleanup_minigames():
	# Liberar lo que esté dentro del overlay
	for child in minigame_overlay.get_children():
		child.queue_free()
	
	# Resetear flags globales
	GlobalManager.is_minigame_overlay_visible = false
	# Resetear también ingredientes recolectados, recetas, etc.
	GlobalManager.collected_ingredients.clear()
	GlobalManager.selected_recipe_idx = -1

func _on_level_cleared():
	print("Nivel completado desde GameController")
	GlobalManager.emit_signal("win")
	_on_win()

func _on_win():
	print("you won")
	load_final_screen(GlobalManager.GameState.WIN)
	
func _on_time_up():
	print("¡Se acabó el tiempo!")
	load_final_screen(GlobalManager.GameState.TIMEUP)

func _on_game_over():
	print("¡GAME OVER!")
	load_final_screen(GlobalManager.GameState.GAMEOVER)
	
func load_final_screen(state: GlobalManager.GameState):
	newton_layer.visible = false
	
	# Limpia si ya había algo
	if final_screen and is_instance_valid(final_screen):
		final_screen.queue_free()
	
	# Instancia la pantalla final
	final_screen = load("res://scenes/ui/FinalScreen.tscn").instantiate()
	overlay_layer.add_child(final_screen)
	
	# Mostrar la pantalla según el estado ("win", "time_up", "game_over")
	final_screen.show_final_screen(state)
