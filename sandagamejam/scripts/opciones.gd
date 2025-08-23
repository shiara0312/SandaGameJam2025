extends Control

# --- Referencias a los nodos ---
@onready var slider_musica := $VBoxContainer/Musica/HSlider
@onready var slider_sfx := $VBoxContainer/SFX/HSlider
@onready var screen_button := $VBoxContainer/Resolucion/OptionButton
@onready var idioma_button := $VBoxContainer/Idioma/OptionButton
@onready var fullscreen_check := $VBoxContainer/Resolucion/CheckButton

# Resoluciones disponibles
var resoluciones = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]

# Idiomas disponibles
var idiomas = {
	"Español": "es",
	"Inglés": "en",
	"Português": "pt"
}

func _ready():
	# --- Poblar opciones ---
	for res in resoluciones:
		screen_button.add_item(str(res.x) + "x" + str(res.y))
		
	for nombre in idiomas.keys():
		idioma_button.add_item(nombre)

	# --- Conectar señales ---
	slider_musica.value_changed.connect(_on_musica_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)
	screen_button.item_selected.connect(_on_resolucion_selected)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	idioma_button.item_selected.connect(_on_idioma_selected)

# --- Volumen música ---
func _on_musica_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))

# --- Volumen SFX ---
func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))

# --- Resolución ---
func _on_resolucion_selected(index: int) -> void:
	var size = resoluciones[index]
	if not fullscreen_check.button_pressed:
		DisplayServer.window_set_size(size)

# --- Pantalla completa ---
func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var idx = screen_button.selected
		if idx >= 0:
			DisplayServer.window_set_size(resoluciones[idx])

# --- Idioma ---
func _on_idioma_selected(index: int) -> void:
	var nombre = idioma_button.get_item_text(index)
	var codigo = idiomas[nombre]
	print("Idioma cambiado a:", nombre)
	TranslationServer.set_locale(codigo)
