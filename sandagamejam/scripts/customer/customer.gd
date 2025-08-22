extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@export var speed: float = 150.0

var relative_x: float = 0.5
var character_id: String
var mood_id: String
var texts: Dictionary
var language: String

# estados del cliente
enum State { ENTERING, SEATED, SATISFIED }
var state = State.ENTERING

# Desde CafeLevel1:
func move_to(target_position: Vector2) -> void:
	print("move to.. ", target_position)
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

func set_state(new_state: State):
	state = new_state
	match state:
		State.ENTERING:
			sprite.texture = preload("res://assets/sprites/ingreso.png")
		State.SEATED:
			sprite.texture = preload("res://assets/sprites/molesto.png")
		State.SATISFIED:
			sprite.texture = preload("res://assets/sprites/satisfecho.png")
