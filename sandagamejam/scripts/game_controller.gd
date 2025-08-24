extends Node

@onready var current_scene_container = $CurrentScene
@onready var minigame_overlay = $MiniGameOverlay
@onready var newton_layer = $NewtonLayer

var current_level: Node = null

# TODO: Animaciones de Newton: idle, feliz, trsite.

func _ready():
	#minigame_overlay.z_index = 0
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
	get_tree().root.add_child(current_level)
	get_tree().current_scene = current_level
	
func show_newton_layer():
	newton_layer.visible = true

func show_minigame(path: String):
	var minigame_instance = load(path).instantiate()
	self.add_child(minigame_instance)
	
	# Obtener la textura principal para calcular ancho
	var tex = minigame_instance.get_node("TextureRect")
	var tex_width = tex.texture.get_width()
	var screen_size = get_viewport().size
	print("tex_width... ", tex_width)
	print("screen size... ", screen_size)

	# Escalar Node2D si quieres (opcional)
	minigame_instance.scale = Vector2(1,1)
	minigame_instance.z_index = 50
	# Posición inicial: fuera de la pantalla (derecha)
	minigame_instance.position = Vector2(screen_size.x, 0)
	print("INIT... ", minigame_instance.position)

	# Posición final: borde izquierdo del Node2D en la mitad de la pantalla
	var target_x = screen_size.x/2
	var target_y = 0
	var target_pos = Vector2(target_x, target_y)

	print("target pos ", target_pos)

	# Tween para entrada del overlay
	var tween = create_tween()
	var screen_width = get_viewport().size.x
	tween.tween_property(minigame_instance, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Animar CurrentScene 1/4 hacia la izquierda
	var target_scene_pos = Vector2(-screen_width/2, current_scene_container.position.y)
	tween.tween_property(current_scene_container, "position", target_scene_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


	#ar screen_size = get_viewport().size
#var tex = minigame_instance.get_node("TextureRect")
#var target_scale = (screen_size.x / 2) / tex.texture.get_width()
#var tex_size_scaled = tex.texture.get_size() * target_scale

# Posicionar Node2D centrado horizontal y un poco hacia arriba
#minigame_instance.position = Vector2(screen_size.x/2 - tex_size_scaled.x/2, screen_size.y/4)
#Así, la imagen quedará centrada horizontalmente.

#screen_size.y/4 → ajustable según quieras que quede más arriba o abajo.

		
	#TODO: Instanciar el Minigame dentro de MinigameLayer.
	#El minijuego ocupa la mitad de la pantalla (puede usar un Control con anchors para centrarse).
	#Newton se mantiene adelante (no lo tapa el minijuego).
	#Al terminar el minijuego
	#El Minijuego instanciado se elimina de MinigameLayer.
	#El personaje resuelve su estado.
	# Nueva posición proporcional considerando el sprit


func hide_minigames():
	for child in minigame_overlay.get_children():
		child.queue_free()

func free_children(parent: Node):
	for child in parent.get_children():
		child.queue_free()
