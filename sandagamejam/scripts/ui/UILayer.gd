#UILayer
extends CanvasLayer

@onready var game_hud : Control = null
@onready var message_texture : TextureRect = null

var typing_speed := 0.01

func _ready() -> void:
	self.layer = 0
	game_hud = $GameHUD
	message_texture = $GameHUD/MessageTexture

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

func show_message(msg_to_display: String = "..."):
	if not message_texture:
		return
	message_texture.visible = true
	var rich_text = message_texture.get_node("RichTextLabel")
	var btn_help = message_texture.get_node("BtnHelp")
	btn_help.visible = false
	
	rich_text.text = ""
	rich_text.visible = true
	
	# Iniciar coroutine de tipeo
	await start_typing(msg_to_display, rich_text)
	
	show_help_button(btn_help)
	#btn_help.visible = true

func hide_message():
	message_texture.visible = true

func show_help_button(btn: TextureButton):
	var label = btn.get_node("Label")
	label.text = GlobalManager.btn_help_customer_label
	btn.visible = true
	
func _on_lives_changed(new_lives):
	game_hud.update_lives(new_lives)

func _on_time_changed(new_time):
	game_hud.update_timer(new_time)

func _on_time_up():
	print("¡Se acabó el tiempo!")

func _on_game_over():
	print("¡GAME OVER!")

func start_typing(msg: String, rich_text: RichTextLabel) -> void:
	var full_text = msg
	rich_text.text = ""
	
	for i in full_text.length():
		rich_text.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout

func _on_btn_help_pressed() -> void:
	AudioManager.play_click_sfx()
	message_texture.visible = false
	if GameController and not GlobalManager.is_minigame_overlay_visible:
		GameController.show_minigame("res://scenes/minigames/MinigameOverlay.tscn")
