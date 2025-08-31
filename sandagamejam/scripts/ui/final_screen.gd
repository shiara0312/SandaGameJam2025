extends Control

@onready var anim = $AnimationPlayer
@onready var bg = $Background
@onready var message = $Message
@onready var score_panel = $ScorePanel
@onready var newton = $Newton

# Preloads de texturas
@onready var bg_win   = preload("res://assets/backgrounds/win.png")
@onready var bg_lose  = preload("res://assets/backgrounds/game_over.png")
@onready var bg_time  = preload("res://assets/backgrounds/timeup.png")
@onready var newton_fail = preload("res://assets/sprites/newtown/newton_sad.png")
@onready var newton_win = preload("res://assets/sprites/newtown/newton_happy.png")

@onready var msg_time = {
	"es" : preload("res://assets/UI/timeup_message_es.png"),
	"en" : preload("res://assets/UI/timeup_message_en.png"),
	"fr" : preload("res://assets/UI/timeup_message_fr.png")
}

@onready var msg_win = {
	"es" : preload("res://assets/UI/win_message_es.png"),
	"en" : preload("res://assets/UI/win_message_en.png"),
	"fr" : preload("res://assets/UI/win_message_fr.png")
}

@onready var msg_lose = {
	"es" : preload("res://assets/UI/game_over_message_es.png"),
	"en" : preload("res://assets/UI/game_over_message_en.png"),
	"fr" : preload("res://assets/UI/game_over_message_fr.png")
}

# state puede ser: "win", "lose", "timeup"
func show_final_screen(state: GlobalManager.GameState):
	AudioManager.stop_game_music()
	score_panel.visible = false
	var lang = GlobalManager.game_language
	match state:
		GlobalManager.GameState.TIMEUP:
			bg.texture = bg_time
			newton.texture = newton_fail
			message.texture = msg_time.get(lang, msg_time["es"])
			AudioManager.play_time_up_sfx()
		GlobalManager.GameState.WIN:
			bg.texture = bg_win
			newton.texture = newton_win
			message.texture = msg_win.get(lang, msg_win["es"])
			AudioManager.play_win_sfx()
		GlobalManager.GameState.GAMEOVER:
			bg.texture = bg_lose
			newton.texture = newton_fail
			message.texture = msg_lose.get(lang, msg_lose["es"])
			AudioManager.play_game_over_sfx()
	
	anim.play("final_sequence")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "final_sequence":
		score_panel.visible = true
		score_panel.modulate.a = 0
		score_panel.create_tween().tween_property(score_panel, "modulate:a", 1.0, 0.4)
