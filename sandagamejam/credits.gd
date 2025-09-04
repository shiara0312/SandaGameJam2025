extends Control

@onready var credits_theme: Theme = preload("res://custom_resources/Credits.tres")
#@onready var scroll: ScrollContainer = $ScrollContainer
#@onready var grid: GridContainer = $ScrollContainer/GridContainer
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var old_grid: GridContainer = $GridContainer2

func _ready():
	self.theme = credits_theme
	
	#scroll.anchor_left = 0.5
	#scroll.anchor_right = 0.5
	#scroll.anchor_top = 0.5
	#scroll.anchor_bottom = 0.5

	#scroll.offset_left = -300
	#scroll.offset_top = -150
	#scroll.offset_right = 300
	#scroll.offset_bottom = 150

	#scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	#scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	# Configuración del VBoxContainer dentro del Scroll
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	_add_credit("Melissa Huerta", "Game Developer & Tech Designer")
	_add_credit("Shiara Arauzo", "Game Developer")
	_add_credit("Malu Munayco", "Game Developer")
	_add_credit("Selene Negrón", "Concept Artist & 2D Artist")
	_add_credit("Ariadna Mestanza", "Concept Artist & 2D Artist")
	_add_credit("Fabrizio Murguia", "Game Designer")

func _add_credit(member: String, role: String):
	print("member fue agregado.. ", member, role)
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_FILL
#	hbox.custom_constants_separation = 20  # separación entre nombre y rol

	var name_label = Label.new()
	name_label.text = member
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#name_label.size_flags_vertical = Control.SIZE_FILL

	var role_label = Label.new()
	role_label.text = role
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	role_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	hbox.add_child(name_label)
	hbox.add_child(role_label)
	vbox.add_child(hbox)


func _on_close_button_pressed() -> void:
	queue_free()
