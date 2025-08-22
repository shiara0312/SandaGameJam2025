extends CanvasLayer

@onready var game_hud : Control = null

func _ready() -> void:
	call_deferred("_init_hud")
	
func _init_hud():
	game_hud = get_node("GameHUD")
	if game_hud:
		game_hud.visible = false
		print("<3 GameHUD SI encontrado")
	else:
		push_error("⚠️ GameHUD NO encontrado")
	
func show_hud():
	if not game_hud:
		call_deferred("show_hud")  # espera a que esté inicializado
		return
	print("show hud fue llamado")
	print("showing........")
	game_hud.visible = true
	game_hud.set_lives(GlobalManager.lives)
	game_hud.set_timer(GlobalManager.time_in_min*60)
