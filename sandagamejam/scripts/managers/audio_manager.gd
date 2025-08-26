extends Node

@onready var sfx_click: AudioStreamPlayer = $SFXClick
@onready var sfx_collect_ingredient: AudioStreamPlayer = $SFXCollectIngredient
@onready var sfx_right_recipe: AudioStreamPlayer = $SFXRightRecipe
@onready var sfx_wrong_recipe: AudioStreamPlayer = $SFXWrongRecipe
@onready var sfx_whisking: AudioStreamPlayer = $SFXWhisking
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
	if sfx_right_recipe:
		sfx_right_recipe.play()
	else:
		push_warning("SFXRightRecipe no está asignado o no existe en AudioManager")
		
func play_wrong_recipe_sfx():	
	if sfx_wrong_recipe:
		sfx_wrong_recipe.play()
	else:
		push_warning("SFXCollectIngredient no está asignado o no existe en AudioManager")

func play_whisking_sfx():	
	if sfx_whisking:
		sfx_whisking.play()
	else:
		push_warning("SFXWhisking no está asignado o no existe en AudioManager")
		

func play_game_music():	
	if game_music:
		game_music.play()
	else:
		push_warning("GameMusic no está asignado o no existe en AudioManager")
