extends Node2D

signal arrived_at_center(customer : Node2D)
signal listen_customer_pressed
	
@onready var sprite : Sprite2D = $Sprite2D
@onready var btn_listen : TextureButton = $BtnListen
@onready var sfx_entering : AudioStreamPlayer = $SFXEntering
@onready var sfx_click : AudioStreamPlayer = $SFXClick
@export var speed: float = 300.0 #DEBUG: 500.0

var start_x = -200
var offset_x = 100
var target_y_ratio := 0.05
var relative_x: float = 0.5
var customer_scale: float = 0.165
var character_id: String
var mood_id: String
var texts: Dictionary
var language: String

# estados del cliente
enum State { ENTERING, SEATED, SATISFIED }
var state = State.ENTERING
	
# Desde CafeLevel1 se llama a:
func move_to(target_position: Vector2) -> void:
	#print("DEBUG > move_to: Customer started moving to...")
	sfx_entering.play()
	
	var dist := (target_position - position).length()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, dist / speed)
	
	# Cuando termine el tween (cliente en el centro) → emitir señal
	tween.finished.connect(customer_positioned)

func customer_positioned():
	print("DEBUG > customer_positioned: Cliente llegó al centro")
	sfx_entering.stop()
	set_state(State.SEATED) #TODO: Cambiar sprite/animación a sentado
	
	var label = btn_listen.get_node("Label")
	label.text = GlobalManager.btn_listen_customer_label
	btn_listen.visible = true
	
	emit_signal("arrived_at_center", self)

# Setup: Preparar, reinicializar data del cliente
func setup(data: Dictionary, lang: String):
	await ready
	character_id = data["character_id"]
	mood_id = data["mood_id"]
	texts = data["texts"]
	language = lang
	# Buscar el botón de forma segura (sin depender de @onready aún)
	btn_listen.visible = false
	# Escala para el sprite
	sprite.scale = Vector2(customer_scale, customer_scale)


func set_state(new_state: State):
	print(">> SETTING STATE ", new_state)
	print("my customer ", character_id, " ", mood_id)
	state = new_state
	match state:
		State.ENTERING:
			var path := "res://assets/sprites/customers/%s_entrando.png" % character_id
			var alt_path := "res://assets/sprites/customers/adalovelace_entrando.png"
			load_customer_texture(path, alt_path)
		State.SEATED:
			var path := "res://assets/sprites/customers/%s_%s.png" % [character_id, mood_id]
			var alt_path := "res://assets/sprites/customers/adalovelace_somnoliento.png"
			load_customer_texture(path, alt_path)
		State.SATISFIED:
			var path := "res://assets/sprites/customers/%s_estable.png" % character_id
			var alt_path := "res://assets/sprites/customers/adalovelace_estable.png"
			load_customer_texture(path, alt_path)

	if sprite.texture:
		position_listen_button()

# Colocar el botón justo arriba del sprite
func position_listen_button():
	if sprite and sprite.texture:
		var texture_size = sprite.texture.get_size() * sprite.scale
		var btn_size = btn_listen.size
		
		# centrar en X, arriba en Y
		var x = -btn_size.x / 2
		var y = -texture_size.y/2 - btn_size.y - 10
		
		btn_listen.position = Vector2(x, y)

#Cargar sprite y aplicar escala.
func get_scaled_size() -> Vector2:
	if sprite.texture:
		return sprite.texture.get_size() * sprite.scale
	return Vector2.ZERO
	
#Calcular su posición inicial (fuera de pantalla, con margen inferior).
func get_initial_position(viewport_size: Vector2) -> Vector2:
	var sprite_size = get_scaled_size()
	var margin_bottom = viewport_size.y * target_y_ratio
	var y = viewport_size.y - (sprite_size.y / 2 + margin_bottom)
	return Vector2(start_x, y)

#Calcular su posición final (centro X, con margen inferior).
func get_target_position(viewport_size: Vector2) -> Vector2:
	var sprite_size = get_scaled_size()
	var margin_bottom = viewport_size.y * target_y_ratio

	var y = viewport_size.y - (sprite_size.y / 2 + margin_bottom)
	return Vector2(viewport_size.x / 2 - offset_x, y)

func _on_btn_listen_pressed() -> void:
	AudioManager.play_click_sfx()
	emit_signal("listen_customer_pressed")

# Helper
func load_customer_texture(path: String, alt_path: String):
	var tex : Texture2D = null
			
	if ResourceLoader.exists(path, "Texture2D"):
		tex = load(path)
	else:
		tex = load(alt_path)
		
	sprite.texture = tex
