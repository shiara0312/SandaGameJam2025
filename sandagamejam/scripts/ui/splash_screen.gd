# splash_screen.gd
extends Control

@export var splash_time: float = 3.0
@onready var splash_texture = $TextureRect
@onready var game_controller = GameController

func _ready():
	var tween = create_tween()
	
	# Fade in
	splash_texture.modulate.a = 0.0
	tween.tween_property(splash_texture, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_interval(1.0)
	
	# Instanciar MainMenu antes de que comience el fade out
	tween.tween_callback(Callable(self, "_show_main_menu"))
	
	# Fade out
	tween.tween_property(splash_texture, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	queue_free()

func _show_main_menu():
	game_controller.load_main_menu()
