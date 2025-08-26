extends Node

@onready var current_scene_container: Node2D = $CurrentSceneContainer
@onready var minigame_overlay = $MiniGameOverlay
@onready var newton_layer = $NewtonLayer
@onready var newton_ready_sprite: Sprite2D = $NewtonLayer/NewtonReadySprite
@onready var newton_moods_sprite: Sprite2D = $NewtonLayer/NewtonMoodsSprite
@onready var recipe_result_text: RichTextLabel = $NewtonLayer/FeedbackMessage

const SCREEN_WIDTH = 1152.0
const SECONDS_TO_LOSE = 30
const SECONDS_TO_GAIN = 15
	
var current_level: Node = null
var newton_original_scale: Vector2 = Vector2(0.22, 0.22)
var newton_original_pos: Vector2 = Vector2(978.0, 472)

# TODO: Animaciones de Newton: idle, feliz, trsite.

func _ready():
	newton_layer.visible = false

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
	
func show_newton_layer():
	newton_layer.visible = true

func show_minigame(path: String):
	var new_scale = 0.15
	var new_scale_vector = Vector2(new_scale, new_scale)
	
	slide_minigame_overlay(path)
	slide_current_level()
	resize_newton_ready(new_scale_vector)
	GlobalManager.is_minigame_overlay_visible = true

func hide_minigames():
	for child in minigame_overlay.get_children():
		child.queue_free()

func free_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()

# Slide Minigame Overlay
func slide_minigame_overlay(path: String):
	const TARGET_X = SCREEN_WIDTH - 700
	
	var tween = create_tween()
	
	var minigame_instance = load(path).instantiate()
	self.add_child(minigame_instance)
	minigame_instance.scale = Vector2(1,1)
	minigame_instance.z_index = 50

	# Posición inicial: fuera de la pantalla (derecha)
	minigame_instance.position = Vector2(SCREEN_WIDTH, 0)
	# Posición final: borde izquierdo del Node2D en la mitad de la pantalla
	var target_pos = Vector2(TARGET_X, 0)
	# Tween para entrada del overlay
	tween.tween_property(minigame_instance, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
# Slide Level scene
func slide_current_level():
	var tween = create_tween()

	var start_scene_pos = current_scene_container.position
	var target_scene_pos = start_scene_pos - Vector2(SCREEN_WIDTH/4, 0)
	tween.tween_property(current_scene_container, "position", target_scene_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func make_newton_cook():	
	# Regresar a "newton_ready" a la posicion y escala inicial 
	newton_ready_sprite.visible = false
	resize_newton_ready(newton_original_scale)
	# Empezar a cocinar
	print("🧑🏽‍🍳 Newton esta cocinando")
	newton_moods_sprite.visible = true
	# TODO: mostrar mensaje que esta2 cocinando 
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
	var result = check_recipe()
	var success = result[0]
	var message = result[1]
	
	recipe_result_text.text = message
	recipe_result_text.visible = true
	# Cambiar sprite según resultado
	if success:
		AudioManager.play_right_recipe_sfx()
		newton_moods_sprite.texture = preload("res://assets/sprites/newtown/newton_win.png")
		print("✅ Receta preparada correctamente")
	else:
		AudioManager.play_wrong_recipe_sfx()
		newton_moods_sprite.texture = preload("res://assets/sprites/newtown/newton_fail.png")
		print("❌ Algo salió mal en la receta")

func check_recipe() -> Array:
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

	var success = correct_recipe_selected and is_exact_match
	# Determinar respuesta y reglas
	var response_type
	if not correct_recipe_selected:
		response_type = GlobalManager.ResponseType.WRONG_RECIPE
		GlobalManager.lose_life()
	elif not is_exact_match:
		response_type = GlobalManager.ResponseType.WRONG_INGREDIENTS
		GlobalManager.apply_penalty(SECONDS_TO_LOSE)
	elif success:
		response_type = GlobalManager.ResponseType.RIGHT_RECIPE_AND_INGREDIENTS
		GlobalManager.apply_penalty(-SECONDS_TO_WIN)
	else:
		response_type = GlobalManager.ResponseType.GRAVITATIONAL_RECIPE 

	var message = GlobalManager.get_response_text(response_type)

	return [success, message]

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
