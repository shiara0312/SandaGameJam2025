extends Node2D

@export var speed: float = 150.0

var character_id: String
var mood_id: String
var texts: Dictionary
var language: String

# estados del cliente
enum State { ENTERING, SEATED, TALKING, READY_TO_HELP }
var state = State.ENTERING

# Desde CafeLevel1:
func move_to(target_position: Vector2, duration: float = -1.0) -> void:
	var dist := (target_position - position).length()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, dist / speed)
	
# Setup: Preparar, reinicializar data del cliente
func setup(data: Dictionary, lang: String):
	character_id = data["character_id"]
	mood_id = data["mood_id"]
	texts = data["texts"]
	language = lang
	$Problem.text = ""
	$BtnListen.hide()
	$BtnHelp.hide()

	#$Problem.text = texts[language]
