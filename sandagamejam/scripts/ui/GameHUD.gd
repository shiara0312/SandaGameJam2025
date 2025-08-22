# GameHUD
extends Control

@export var full_heart : Texture
@export var empty_heart : Texture

@onready var hearts = [$HUDContainer/Heart1, $HUDContainer/Heart2, $HUDContainer/Heart3]
@onready var timer_label = $HUDContainer/TimerLabel
	
func update_lives(value: int):
	for i in range(hearts.size()):
		hearts[i].texture = full_heart if i < value else empty_heart
			
func update_timer(seconds: int):
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	timer_label.text = str(mins).pad_zeros(2) + ":" + str(secs).pad_zeros(2)
