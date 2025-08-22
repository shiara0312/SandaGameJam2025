#UILayer
extends CanvasLayer

@onready var game_hud : Control = null

func _ready() -> void:
	game_hud = $GameHUD
	if game_hud:
		game_hud.visible = false
	else:
		# Esperar al frame siguiente si aún no existe
		call_deferred("_ready")
	
	GlobalManager.connect("lives_changed", Callable(self, "_on_lives_changed"))
	GlobalManager.connect("time_changed", Callable(self, "_on_time_changed"))
	GlobalManager.connect("time_up", Callable(self, "_on_time_up"))
	GlobalManager.connect("game_over", Callable(self, "_on_game_over"))
	
func show_hud():
	if not game_hud:
		return

	game_hud.visible = true
	_on_lives_changed(GlobalManager.lives)
	_on_time_changed(GlobalManager.time_left)

func _on_lives_changed(new_lives):
	game_hud.update_lives(new_lives)

func _on_time_changed(new_time):
	game_hud.update_timer(new_time)

func _on_time_up():
	print("¡Se acabó el tiempo!")

func _on_game_over():
	print("¡GAME OVER!")
