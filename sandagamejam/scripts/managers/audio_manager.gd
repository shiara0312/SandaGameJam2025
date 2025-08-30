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
