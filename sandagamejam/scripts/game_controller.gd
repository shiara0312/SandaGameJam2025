extends Node

@onready var current_scene_container: Node2D = $CurrentSceneContainer
@onready var minigame_overlay = $MiniGameOverlay
@onready var newton_layer = $NewtonLayer

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
	#get_tree().root.add_child(current_level)
	#get_tree().current_scene = current_level
	
func show_newton_layer():
	newton_layer.visible = true

func show_minigame(path: String):
	GlobalManager.is_minigame_overlay_visible = true
	var tween = create_tween()
	var screen_width = get_viewport().size.x
	#var screen_height = get_viewport().size.y
	
	# Slide Minigame Overlay
	var minigame_instance = load(path).instantiate()
	self.add_child(minigame_instance)
	# Escalar Node2D si quieres (opcional)
	minigame_instance.scale = Vector2(1,1)
	minigame_instance.z_index = 50
	
	var overlay_width = minigame_instance.get_node("TextureRect").texture.get_size().x
	
	# Posición inicial: fuera de la pantalla (derecha)
	minigame_instance.position = Vector2(screen_width, 0)
	print("INIT... ", minigame_instance.position)
	# Posición final: borde izquierdo del Node2D en la mitad de la pantalla
	var target_x = screen_width - overlay_width
	var target_pos = Vector2(target_x, 0)

	print("target pos ", target_pos)


	# Tween para entrada del overlay
	tween.tween_property(minigame_instance, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Slide Level scene

	
	

	# current_scene_container es Node2D, su hijo es un Control que ocupa toda la pantalla

	var start_scene_pos = current_scene_container.position
	print("start at .. ", start_scene_pos)
	var target_scene_pos = start_scene_pos - Vector2(screen_width/4, 0)
	print("target_scene_pos .. ", target_scene_pos)
	tween.tween_property(current_scene_container, "position", target_scene_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


		
	#TODO: Al terminar el minijuego
	#El Minijuego instanciado se elimina de MinigameLayer.
	#El personaje resuelve su estado.
	# Nueva posición proporcional considerando el sprit


func hide_minigames():
	for child in minigame_overlay.get_children():
		child.queue_free()

func free_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()
