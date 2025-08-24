extends Node

@onready var sfx_click: AudioStreamPlayer = $SFXClick

func play_click_sfx():	
	if sfx_click:
		sfx_click.play()
	else:
		push_warning("SFXClick no está asignado o no existe en AudioManager")
