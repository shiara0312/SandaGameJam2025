#UILayer
#HUD + manager de mensajes y botones,
extends CanvasLayer

@onready var game_hud : Control = null
@onready var message_texture : TextureRect = null
@onready var pause_btn = $PauseBtn
@export var pause_texture: Texture
@export var play_texture: Texture
@onready var timer_label: Label = $GameHUD/HUDContainer/TimerLabel

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
	
	if timer_label:
		timer_label.add_theme_color_override("font_color", Color("#a79e91"))
		timer_label.add_theme_color_override("font_outline_color", Color("#19211f"))
		timer_label.add_theme_constant_override("outline_size", 10)
		
	GlobalManager.connect("lives_changed", Callable(self, "_on_lives_changed"))
	GlobalManager.connect("time_changed", Callable(self, "_on_time_changed"))
	GlobalManager.connect("time_up", Callable(self, "_on_hide_ui"))
	GlobalManager.connect("game_over", Callable(self, "_on_hide_ui"))
	GlobalManager.connect("win", Callable(self, "_on_hide_ui"))
	
	if GameController.has_signal("ingredients_minigame_finished"):
		GameController.connect("ingredients_minigame_finished", Callable(self, "_on_ingredients_minigame_exit"))
	
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

func hide_message():
	message_texture.visible = true

func show_help_button(btn: TextureButton):
	var label = btn.get_node("Label")
	label.text = GlobalManager.btn_help_customer_label
	btn.visible = true
	
func _on_lives_changed(new_lives):
	game_hud.update_hud(new_lives, GlobalManager.max_lives)

func _on_time_changed(new_time):
	game_hud.update_timer(new_time)

func start_typing(msg: String, rich_text: RichTextLabel) -> void:
	var full_text = msg
	rich_text.text = ""
	
	for i in full_text.length():
		rich_text.text += full_text[i]
		await get_tree().create_timer(typing_speed).timeout

# Invertir colores del timer_label
func invest_label_colors():
	if timer_label:
		var font_color = timer_label.get_theme_color("font_color", "Label")
		var outline_color = timer_label.get_theme_color("font_outline_color", "Label")

		timer_label.add_theme_color_override("font_color", outline_color)
		timer_label.add_theme_color_override("font_outline_color", font_color)
		timer_label.add_theme_constant_override("outline_size", 6)

func _on_btn_help_pressed() -> void:
	AudioManager.play_click_sfx()
	AudioManager.stop_customer_sfx()
	message_texture.visible = false
	invest_label_colors()
	
	if GameController and not GlobalManager.is_minigame_overlay_visible:
		GameController.show_minigame("res://scenes/minigames/MinigameOverlay.tscn")

func _on_pause_btn_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_btn.texture_normal = pause_texture
	else:
		get_tree().paused = true
		pause_btn.texture_normal = play_texture

func _on_hide_ui():
	visible = false

func _on_ingredients_minigame_exit() -> void:
	invest_label_colors()
