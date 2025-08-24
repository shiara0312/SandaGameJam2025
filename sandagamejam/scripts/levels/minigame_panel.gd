# MinigameOverlay.tscn
extends Node2D

func _ready():
	print("ready >> ", GlobalManager.ingredients)
	print("ready >> ", GlobalManager.current_level_recipes)
