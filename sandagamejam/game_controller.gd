extends Node

@onready var current_scene_container = $CurrentScene
@onready var minigame_overlay = $MiniGameOverlay
@onready var newton_layer = $NewtonLayer

var current_level: Node = null

# TODO: Animaciones de Newton: idle, feliz, trsite.
	
func load_level(level_path: String) -> void:
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
	
	var scene = load(level_path)
	if not scene:
		push_error("No se encontró la escena: " + level_path)
		return
	
	current_level = scene.instantiate()
	get_tree().root.add_child(current_level)
	get_tree().current_scene = current_level
	
func show_newton_layer():
	newton_layer.visible = true

func show_minigame(path: String):
	var minigame = load(path).instantiate()
	minigame_overlay.add_child(minigame)
#TODO: Instanciar el Minigame dentro de MinigameLayer.
	#El minijuego ocupa la mitad de la pantalla (puede usar un Control con anchors para centrarse).
	#Newton se mantiene adelante (no lo tapa el minijuego).
	#Al terminar el minijuego
	#El Minijuego instanciado se elimina de MinigameLayer.
	#El personaje resuelve su estado.
	# Nueva posición proporcional considerando el sprite

func hide_minigames():
	free_children(minigame_overlay)

func free_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()
