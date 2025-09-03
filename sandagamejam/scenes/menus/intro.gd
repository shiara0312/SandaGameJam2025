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
var typing_speed := 0.05
var typing_timer: Timer
var full_text := ""
var char_index := 0
var current_index = 0
var is_typing := false

func _ready():
	# animacion
	typing_timer = Timer.new()
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = false
	typing_timer.timeout.connect(Callable(self, "_on_typing_timeout"))
	add_child(typing_timer)
	
	_show_text(texts[current_index])
	
	button_label.text = "Continuar" 
	btn_start.pressed.connect(_on_btn_start_pressed)
	if has_node("BtnBack"):
		btn_back.pressed.connect(_on_btn_back_pressed)

func _show_text(new_text: String):
	full_text = new_text
	char_index = 0
	text_intro.text = ""
	is_typing = true
	typing_timer.start()
	
func _on_typing_timeout():
	if char_index < full_text.length():
		text_intro.text += full_text[char_index]
		char_index += 1
	else:
		typing_timer.stop()
		is_typing = false

func _on_btn_start_pressed():
	
	AudioManager.play_click_sfx()
	
	if is_typing:
		text_intro.text = full_text
		typing_timer.stop()
		is_typing = false
		return
		
	current_index += 1
	if current_index < texts.size():
		_show_text(texts[current_index])

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
