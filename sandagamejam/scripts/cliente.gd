extends Node2D

var character_id: String
var mood_id: String
var texts: Dictionary

func setup(data: Dictionary, language: String):
	character_id = data["character_id"]
	mood_id = data["mood_id"]
	texts = data["texts"]
	$Problematica.text = texts[language]
