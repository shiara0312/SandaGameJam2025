#UILayer
#HUD + manager de mensajes y botones
extends CanvasLayer

@onready var game_hud : Control = null
@onready var message_texture : TextureRect = null
@onready var pause_btn = $PauseBtn
@export var pause_texture: Texture
@export var play_texture: Texture
@onready var timer_label: Label = $GameHUD/HUDContainer/TimerLabel
#Enciclopedia -> TODO: cambiar a una escena independiente
@onready var encyclopedia_ui = $EncyclopediaUI
@onready var tools_btn = $ToolsBtn
@onready var tab_container = $EncyclopediaUI/Panel/TabContainer
@onready var ingredients_box = $EncyclopediaUI/Panel/TabContainer/IngredientsTab/VBoxContainer
@onready var characters_box = $EncyclopediaUI/Panel/TabContainer/CharactersTab/MarginContainer/VBoxContainer
var font = load("res://assets/fonts/Macondo/Macondo-Regular.ttf")

var typing_speed := 0.01
var characters_data = null

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
	
	
	# Datos para la enciclopedia
	characters_data = FileHelper.read_data_from_file("res://i18n/characters_moods.json")
	characters_data = characters_data["characters"]
	_build_tabs()


func show_hud():
	if not game_hud:
		return

	game_hud.visible = true
	_on_lives_changed(GlobalManager.lives, GlobalManager.max_lives)
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
	
func _on_lives_changed(new_lives, max_lives):
	game_hud.update_hud(new_lives, max_lives)

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

# Ayudar al cliente
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
	
# Funciones para la enciclopedia:
func _on_tools_btn_pressed() -> void:
	encyclopedia_ui.visible = true
	get_tree().paused = true

func _on_close_btn_pressed() -> void:
	encyclopedia_ui.visible = false
	get_tree().paused = false

func _build_tabs():
	var lang = GlobalManager.game_language
	# Limpia todos los hijos antes de reconstruir
	for child in characters_box.get_children():
		child.queue_free()
	
	for chart in characters_data:
		var hbox = HBoxContainer.new()
		
		# Sprite
		var sprite_path = "res://assets/sprites/customers/%s_happy.png" % chart["id"]
		var tex = load(sprite_path)
		if tex:
			var tex_rect = TextureRect.new()
			tex_rect.texture = tex
			tex_rect.custom_minimum_size = Vector2(250, 250)
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			hbox.add_child(tex_rect)
		
		# Textos
		var vbox = VBoxContainer.new()
		vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		# Nombre
		var name_label = Label.new()
		name_label.text = chart["name"].get(lang, chart["name"]["en"])
		name_label.add_theme_font_size_override("font_size", 18)
		
		# Especialidad
		var esp_label = Label.new()
		esp_label.text = str(chart["specialty"][GlobalManager.game_language])
		
		# Descripcion
		var desc_label = Label.new()
		desc_label.text = str(chart["description"][GlobalManager.game_language])
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size = Vector2(500, 0)
		
		vbox.add_child(name_label)
		vbox.add_child(esp_label)
		vbox.add_child(desc_label)
		hbox.add_child(vbox)

		# Agregar fila al VBox principal
		characters_box.add_child(hbox)
		apply_font_to_labels(characters_box, font, 24)

func populate_ingredients_list(vbox: VBoxContainer) -> void:
	vbox.queue_free_children()

	# Concatenar todos los ingredientes en una sola lista
	var all_ingredients = []
	all_ingredients += GlobalManager.all_ingredients
	all_ingredients += GlobalManager.fake_ingredients
	all_ingredients += GlobalManager.gravitational_ingredients

	for ing in all_ingredients:
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		# Imagen
		var sprite_path = "res://assets/pastry/ingredients/%s.png" % ing["id"]
		var tex = load(sprite_path)
		if tex:
			var tex_rect = TextureRect.new()
			tex_rect.texture = tex
			tex_rect.custom_minimum_size = Vector2(64, 64)
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			hbox.add_child(tex_rect)

		# Texto
		var label = Label.new()
		label.text = ing["name"].get("es", ing["id"])
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hbox.add_child(label)

		vbox.add_child(hbox)


func apply_font_to_labels(node: Node, font: FontFile, size: int = 16) -> void:
	for child in node.get_children():
		if child is Label:
			child.add_theme_font_override("font", font)
			child.add_theme_font_size_override("font_size", size)
		elif child.get_child_count() > 0:
			# Aplicar también a hijos dentro de sub-contenedores
			apply_font_to_labels(child, font, size)
