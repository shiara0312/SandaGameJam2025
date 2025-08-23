extends Control

@onready var slider_musica := $MusicaSlider
@onready var slider_sfx := $SFXsLider
@onready var screen_button := $Pantalla
@onready var idioma_button := $Idioma

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

func _ready():
	for res in resoluciones:
		screen_button.add_item(str(res.x) + "x" + str(res.y))

	screen_button.add_item("Pantalla Completa")

	for nombre in idiomas.keys():
		idioma_button.add_item(nombre)

	slider_musica.value_changed.connect(_on_musica_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)
	screen_button.item_selected.connect(_on_resolucion_selected)
	idioma_button.item_selected.connect(_on_idioma_selected)


func _on_musica_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))

func _on_sfx_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))


func _on_resolucion_selected(index: int) -> void:
	if index < resoluciones.size():
		var size = resoluciones[index]
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(size)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_idioma_selected(index: int) -> void:
	var nombre = idioma_button.get_item_text(index)
	var codigo = idiomas[nombre]
	print("Idioma cambiado a:", nombre)
	TranslationServer.set_locale(codigo)


func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://MainScene.tscn")
