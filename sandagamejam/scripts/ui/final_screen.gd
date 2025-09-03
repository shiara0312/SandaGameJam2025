extends Control

@onready var anim = $AnimationPlayer
@onready var bg = $Background
@onready var message = $Message
@onready var score_panel = $ScorePanel
@onready var newton = $Newton
@onready var score_container = $ScoreContainer
@onready var score_label = $ScoreContainer/Score
@onready var name_label = $ScoreContainer/Name
@onready var ranking_container = $RankingContainer 

# Preloads de texturas
@onready var bg_win   = preload("res://assets/backgrounds/good_score_bg.png")
@onready var bg_lose  = preload("res://assets/backgrounds/bad_score_bg.png")
@onready var newton_fail = preload("res://assets/sprites/newtown/newton_sad.png")
@onready var newton_win = preload("res://assets/sprites/newtown/newton_happy.png")
@onready var ranking_label_settings: LabelSettings = preload("res://custom_resources/Ranking.tres")

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

var score: int = 100
var max_name_length: int = 6
var current_name: Array = []
var ranking: Array = []
var ranking_labels = GlobalManager.menu_labels[GlobalManager.game_language]

func _ready():
	if GlobalManager.satisfied_customers.size() == 0:
		score = 0
	else:
		score = (round(GlobalManager.time_left) * 10) + (GlobalManager.lives * 100)
	
	print("GlobalManager.menu_labels", ranking_labels)
	score_label.text = ranking_labels["ranking"]["score"] + " " + str(score) 
	show_name_label()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		#a-z y A-Z
		if (event.unicode >= 65 and event.unicode <=90) or (event.unicode >= 97 and event.unicode <= 122):
			var char_typed = char(event.unicode).to_upper()
			if current_name.size() < max_name_length:
				current_name.append(char_typed)
				show_name_label()
			# Luego del enter
		elif event.keycode == KEY_BACKSPACE and current_name.size() > 0:
				current_name.pop_back()
				show_name_label()
			# Borrar letra
		elif event.keycode == KEY_ENTER and current_name.size() > 0:
				store_in_ranking("".join(current_name), score)
				show_ranking()
	
# state puede ser: "win", "lose", "timeup"
func show_final_screen(state: GlobalManager.GameState):
	AudioManager.stop_game_music()
	score_panel.visible = false
	var lang = GlobalManager.game_language
	match state:
		GlobalManager.GameState.TIMEUP:
			bg.texture = bg_lose
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
	
func show_name_label():
	var display = ""
	for i in range(max_name_length):
		if i < current_name.size():
			display += current_name[i] + ""
		else:
			display += "_"
	name_label.text =  ranking_labels["ranking"]["name"] + " " + display 

func store_in_ranking(username: String, score_value: int):
	ranking.append({"name": username, "score": score_value})
	# Ordenar de mayor a menor score
	ranking.sort_custom(func(a, b): return b.score - a.score)
	if ranking.size() > 10:
		ranking = ranking.slice(0, 10)

func show_ranking():
	message.visible = false
	score_container.visible = false
	
	for child in ranking_container.get_children():
		child.queue_free()
	
	# Crear un label por cada item en ranking
	for i in range(ranking.size()):
		var entry = ranking[i]
		var label = Label.new()
		label.text = str(i+1)+". " + entry.name +" - " + str(entry.score)
		label.label_settings = ranking_label_settings
		ranking_container.add_child(label)
		
	ranking_container.visible = true
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "final_sequence":
		score_panel.visible = true
		score_panel.modulate.a = 0
		score_panel.create_tween().tween_property(score_panel, "modulate:a", 1.0, 0.4)
