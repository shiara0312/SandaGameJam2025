extends Sprite2D

func _ready():
	var viewport_size = get_viewport().size / 2.0 # convertir a float
	var base_size = Vector2(1152, 648)
	scale = viewport_size / base_size
