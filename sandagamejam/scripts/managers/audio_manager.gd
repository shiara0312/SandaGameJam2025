extends Node

@onready var sfx_click: AudioStreamPlayer = $SFXClick
@onready var game_music: AudioStreamPlayer = $GameMusic

func play_click_sfx():	
	if sfx_click:
		sfx_click.play()
	else:
		push_warning("SFXClick no está asignado o no existe en AudioManager")
		
func play_game_music():	
	if game_music:
		game_music.play()
	else:
		push_warning("GameMusic no está asignado o no existe en AudioManager")
