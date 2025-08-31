# AudioManager.gd
extends Node

@onready var sfx_click: AudioStreamPlayer = $SFXClick
@onready var sfx_collect_ingredient: AudioStreamPlayer = $SFXCollectIngredient
@onready var sfx_recipe_good: AudioStreamPlayer = $SFXRecipeGood
@onready var sfx_recipe_bad: AudioStreamPlayer = $SFXRecipeBad
@onready var sfx_whisking: AudioStreamPlayer = $SFXWhisking
@onready var sfx_time_up: AudioStreamPlayer = $SFXTimeUp
@onready var sfx_game_over: AudioStreamPlayer = $SFXGameOver
@onready var sfx_win: AudioStreamPlayer = $SFXWin
@onready var game_music: AudioStreamPlayer = $GameMusic
@onready var sfx_customer_complaint := AudioStreamPlayer.new()

var sfx_complaint_dict := {
	"female_sad": preload("res://assets/sfx/characters/sfx_female_sad.ogg"),
	"female_annoyed": preload("res://assets/sfx/characters/sfx_female_annoyed.ogg"),
	"female_stressed": preload("res://assets/sfx/characters/sfx_female_stressed.ogg"),
	"female_sleepy": preload("res://assets/sfx/characters/sfx_female_sleepy.ogg"),
	"female_happy": preload("res://assets/sfx/characters/sfx_female_happy.ogg"),
	"male_sad": preload("res://assets/sfx/characters/sfx_male_sad.ogg"),
	"male_annoyed": preload("res://assets/sfx/characters/sfx_male_annoyed.ogg"),
	"male_stressed": preload("res://assets/sfx/characters/sfx_male_stressed.ogg"),
	"male_sleepy": preload("res://assets/sfx/characters/sfx_male_sleepy.ogg"),
	"male_happy": preload("res://assets/sfx/characters/sfx_male_happy.ogg"),
}

func _ready():
	add_child(sfx_customer_complaint)

func play_click_sfx():	
	if sfx_click:
		sfx_click.play()
	else:
		push_warning("SFXClick no está asignado o no existe en AudioManager")
		
func play_collect_ingredient_sfx():	
	if sfx_collect_ingredient:
		sfx_collect_ingredient.play()
	else:
		push_warning("SFXCollectIngredient no está asignado o no existe en AudioManager")
		
func play_right_recipe_sfx():	
	if sfx_recipe_good:
		sfx_recipe_good.play()
	else:
		push_warning("SFXRightRecipe no está asignado o no existe en AudioManager")
		
func play_wrong_recipe_sfx():	
	if sfx_recipe_bad:
		sfx_recipe_bad.play()
	else:
		push_warning("SFXCollectIngredient no está asignado o no existe en AudioManager")

func play_whisking_sfx():	
	if sfx_whisking:
		sfx_whisking.play()
	else:
		push_warning("SFXWhisking no está asignado o no existe en AudioManager")

func play_customer_sfx(genre: String, mood_id: String, is_result: bool = false) -> void:
	var key = "%s_%s" % [genre, mood_id]
	if sfx_complaint_dict.has(key):
		sfx_customer_complaint.stream = sfx_complaint_dict[key]
		sfx_customer_complaint.stream.loop = not is_result
		sfx_customer_complaint.volume_db = -10.0
		sfx_customer_complaint.play()
	else:
		push_warning("Audio no encontrado: " + key)
		
func play_time_up_sfx():	
	if sfx_time_up:
		sfx_time_up.play()
	else:
		push_warning("SFXTimeUp no está asignado o no existe en AudioManager")

func play_game_over_sfx():	
	if sfx_game_over:
		sfx_game_over.play()
	else:
		push_warning("SFXGameOver no está asignado o no existe en AudioManager")

func play_win_sfx():	
	if sfx_win:
		sfx_win.play()
	else:
		push_warning("SFXWin no está asignado o no existe en AudioManager")

func play_game_music():	
	if game_music:
		game_music.play()
	else:
		push_warning("GameMusic no está asignado o no existe en AudioManager")

func stop_whisking_sfx():	
	if sfx_whisking and sfx_whisking.playing:
		sfx_whisking.stop()
	else:
		push_warning("SFXWhisking no está asignado o no existe en AudioManager")

func stop_game_music():
	if game_music and game_music.playing:
		game_music.stop()
	else:
		push_warning("GameMusic no está asignado o no existe en AudioManager")

func stop_customer_sfx() -> void:
	if sfx_customer_complaint.playing:
		sfx_customer_complaint.stop()
