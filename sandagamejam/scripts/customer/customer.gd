extends Node2D

signal arrived_at_center(customer : Node2D)

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
	print("move_to: Customer started moving to...")
	var dist := (target_position - position).length()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, dist / speed)
	
	# Cuando termine el tween (cliente en el centro) → emitir señal
	tween.finished.connect(customer_positioned)

func customer_positioned():
	print("Cliente llegó al centro")
	set_state(State.SEATED) # Cambiar sprite/animación a sentado
	emit_signal("arrived_at_center", self)

# Setup: Preparar, reinicializar data del cliente
func setup(data: Dictionary, lang: String):
	print("setup.. ", data)
	character_id = data["character_id"]
	mood_id = data["mood_id"]
	texts = data["texts"]
	language = lang
	$BtnListen.hide()

func set_state(new_state: State):
	state = new_state
	match state:
		State.ENTERING:
			sprite.texture = preload("res://assets/sprites/ingreso.png")
		State.SEATED:
			sprite.texture = preload("res://assets/sprites/molesto.png")
		State.SATISFIED:
			sprite.texture = preload("res://assets/sprites/satisfecho.png")
