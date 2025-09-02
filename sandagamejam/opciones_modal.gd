extends Control

@onready var slider_musica := $MusicaSlider
@onready var slider_sfx := $SFXsLider
@onready var screen_button := $Pantalla
@onready var idioma_button := $Idioma

@onready var label_musica := $LabelMusica
@onready var label_sfx := $LabelSFX
@onready var label_idioma := $LabelIdioma
@onready var label_resolucion := $LabelResolucion

var resoluciones = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]

var idiomas = {
	"Español": "es",
	"English": "en",
	"Français": "fr"
}

var labels_por_idioma = {
	"es": {
		"musica": "Música",
		"sfx": "SFX",
		"idioma": "Idioma",
		"resolucion": "Resolución de Pantalla"
	},
	"en": {
		"musica": "Music",
		"sfx": "SFX",
		"idioma": "Language",
		"resolucion": "Screen Resolution"
	},
	"fr": {
		"musica": "Musique",
		"sfx": "SFX",
		"idioma": "Langue",
		"resolucion": "Résolution d’écran"
	}
}

func _ready():
	# Rellenar resoluciones
	for res in resoluciones:
		screen_button.add_item(str(res.x) + "x" + str(res.y))
	screen_button.add_item("Pantalla Completa")

	# Rellenar idiomas
	for nombre in idiomas.keys():
		idioma_button.add_item(nombre)

	# Conectar señales
	slider_musica.value_changed.connect(_on_musica_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)
	screen_button.item_selected.connect(_on_resolucion_selected)
	idioma_button.item_selected.connect(_on_idioma_selected)

	# Seleccionar idioma actual
	for i in range(idioma_button.get_item_count()):
		if idiomas[idioma_button.get_item_text(i)] == GlobalManager.game_language:
			idioma_button.select(i)
			break

	# 🔊 Inicializar sliders con valores actuales de audio
	var vol_musica_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	var vol_sfx_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))

	# Si el bus está en -80 dB (muteado por default), arrancamos en 100%
	if vol_musica_db <= -79.0:
		slider_musica.value = 100.0
	else:
		slider_musica.value = db_to_linear(vol_musica_db) * 100.0

	if vol_sfx_db <= -79.0:
		slider_sfx.value = 100.0
	else:
		slider_sfx.value = db_to_linear(vol_sfx_db) * 100.0

	_actualizar_labels()

func _on_musica_changed(value: float) -> void:
	var vol = clamp(value / 100.0, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(vol))

func _on_sfx_changed(value: float) -> void:
	var vol = clamp(value / 100.0, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(vol))

func _on_resolucion_selected(index: int) -> void:
	if index < resoluciones.size():
		var new_size = resoluciones[index]
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(new_size)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_idioma_selected(index: int) -> void:
	var nombre = idioma_button.get_item_text(index)
	var codigo = idiomas[nombre]
	GlobalManager.game_language = codigo
	_actualizar_labels()

func _actualizar_labels():
	var idioma = GlobalManager.game_language
	if label_musica:
		label_musica.text = labels_por_idioma.get(idioma, {}).get("musica", "Música")
	if label_sfx:
		label_sfx.text = labels_por_idioma.get(idioma, {}).get("sfx", "SFX")
	if label_idioma:
		label_idioma.text = labels_por_idioma.get(idioma, {}).get("idioma", "Idioma")
	if label_resolucion:
		label_resolucion.text = labels_por_idioma.get(idioma, {}).get("resolucion", "Resolución de Pantalla")

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
