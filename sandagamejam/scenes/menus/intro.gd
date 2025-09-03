extends Node2D

@onready var btn_start: TextureButton = $Comenzar_Game
@onready var btn_back: Button = $BtnBack   # si tienes un botón volver

func _ready():
	# Conectar señales de los botones
	btn_start.pressed.connect(_on_btn_start_pressed)
	if has_node("BtnBack"):
		btn_back.pressed.connect(_on_btn_back_pressed)

# Cuando presionas "Comenzar"
func _on_btn_start_pressed():
	AudioManager.play_click_sfx()

	var level_1_path = "res://scenes/levels/PastryLevel1.tscn"

	# Cambia la escena al primer nivel
	get_tree().change_scene_to_file(level_1_path)

	# Inicia el juego en tus managers
	GlobalManager.start_game()
	GameController.load_level(level_1_path)
	GameController.show_newton_layer()

# Cuando presionas "Volver al Menú"
func _on_btn_back_pressed():
	AudioManager.play_click_sfx()
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
