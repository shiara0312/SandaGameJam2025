extends Node

@onready var current_scene_container: Node2D = $CurrentSceneContainer
@onready var minigame_overlay = $MiniGameOverlay
@onready var newton_layer = $NewtonLayer
@onready var newton_sprite: Sprite2D = $NewtonLayer/NewtonSprite

var current_level: Node = null

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
	GlobalManager.is_minigame_overlay_visible = true
	var screen_width = get_viewport().size.x
	var new_scale = 0.15
	
	slide_minigame_overlay(path, screen_width)
	slide_current_level(screen_width)
	resize_newton(new_scale)
	load_recipes()

func hide_minigames():
	for child in minigame_overlay.get_children():
		child.queue_free()
	#TODO: Al terminar el minijuego
	#El Minijuego instanciado se elimina de MinigameLayer.
	#El personaje resuelve su estado.
	# Nueva posición proporcional considerando el sprit

func free_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()

# Slide Minigame Overlay
func slide_minigame_overlay(path: String, screen_width: float):
	var tween = create_tween()
	
	var minigame_instance = load(path).instantiate()
	self.add_child(minigame_instance)
	minigame_instance.scale = Vector2(1,1)
	minigame_instance.z_index = 50
	
	var overlay_width = minigame_instance.get_node("TextureRect").texture.get_size().x
	
	# Posición inicial: fuera de la pantalla (derecha)
	minigame_instance.position = Vector2(screen_width, 0)
	# Posición final: borde izquierdo del Node2D en la mitad de la pantalla
	var target_x = screen_width - overlay_width
	var target_pos = Vector2(target_x, 0)
	# Tween para entrada del overlay
	tween.tween_property(minigame_instance, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
# Slide Level scene
func slide_current_level(screen_width: float):
	var tween = create_tween()

	var start_scene_pos = current_scene_container.position
	var target_scene_pos = start_scene_pos - Vector2(screen_width/4, 0)
	tween.tween_property(current_scene_container, "position", target_scene_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func resize_newton(new_scale: float) -> void:
	var tween = create_tween()
	
	# Escalar con animación
	tween.tween_property(newton_sprite, "scale", Vector2(new_scale, new_scale), 0.5)
	
	# Mover con animación (20px más abajo/derecha de su posición actual)
	var new_pos = newton_sprite.position + Vector2(84,100)
	tween.tween_property(newton_sprite, "position", new_pos, 0.5)

func load_recipes():
	print("load to ui ")
