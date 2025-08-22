extends Control

@export var full_heart : Texture
@export var empty_heart : Texture

@onready var hearts = [$HUDContainer/Heart1, $HUDContainer/Heart2, $HUDContainer/Heart3]
@onready var timer_label = $HUDContainer/TimerLabel

var lives : int = GlobalManager.lives

func set_lives(value: int):
	print("setting lives")
	lives = clamp(value, 0, lives)
	for i in range(lives):
		if i < lives:
			hearts[i].texture = full_heart
		else:
			hearts[i].texture = empty_heart
			

func lose_life():
	set_lives(lives - 1)
	
func set_timer(seconds: int):
	var mins = int(seconds / 60)
	var secs = int(seconds % 60)
	timer_label.text = str(mins).pad_zeros(2) + ":" + str(secs).pad_zeros(2)
