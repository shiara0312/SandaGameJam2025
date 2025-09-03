# GameHUD
extends Control

@export var full_heart : Texture
@export var empty_heart : Texture

@onready var hearts_container = $HUDContainer/Hearts
#@onready var hearts = [$HUDContainer/Heart1, $HUDContainer/Heart2, $HUDContainer/Heart3]
@onready var timer_label = $HUDContainer/TimerLabel
	
func _ready() -> void:
	GlobalManager.lives_changed.connect(update_hud)
	update_hud(GlobalManager.lives, GlobalManager.max_lives)

# Reconstruir el UI de corazones
func update_hud(current: int, max_lives: int):
	for child in hearts_container.get_children():
		child.queue_free()
	
	for i in range(max_lives):
		var heart_sprite = TextureRect.new()
		heart_sprite.texture = full_heart if i < current else empty_heart
		heart_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart_sprite)

func update_timer(seconds: int):
	var mins = div_int(seconds, 60)
	var secs = int(seconds % 60)
	timer_label.text = str(mins).pad_zeros(2) + ":" + str(secs).pad_zeros(2)


func div_int(a, b):
	return int(a / b)
