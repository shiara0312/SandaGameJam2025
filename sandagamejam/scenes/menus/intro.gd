extends Node2D

@onready var btn_start: TextureButton = $Comenzar_Game
@onready var button_label: Label = $Comenzar_Game/button_label
@onready var text_intro = $text_intro
@onready var btn_back: Button = $BtnBack if has_node("BtnBack") else null # si tienes un botón volver

var texts = [
	"Sir Isaac Newton, cansado de que le caigan manzanas en la cabeza, abrió una pastelería...",
	"Ahora debe combinar ingredientes secretos para complacer a sus clientes exigentes...",
	"¡Tu aventura como maestro pastelero comienza ahora!"
]
var current_index = 0
func _ready():
	text_intro.text = texts[current_index]
	btn_start.pressed.connect(_on_btn_start_pressed)
	if has_node("BtnBack"):
		btn_back.pressed.connect(_on_btn_back_pressed)

func _on_btn_start_pressed():
	
	AudioManager.play_click_sfx()
	current_index += 1
	if current_index < texts.size():

		text_intro.text = texts[current_index]


		if current_index == texts.size() - 1:
			button_label.text = "Jugar"
	else:
		# Tercer click iniciar juego
		var level_1_path = "res://scenes/levels/PastryLevel1.tscn"
		GlobalManager.start_game()
		GameController.load_level(level_1_path)
		GameController.show_newton_layer()


func _on_btn_back_pressed():
	AudioManager.play_click_sfx()
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
