extends Node2D


@export var spawn_y: float = 400
@export var spawn_interval: float = 2.0
@export var speed: float = 150
@export var max_on_screen: int = 8

@onready var food_item_scene := preload("res://scenes/food/FoodItem.tscn")
var ingredient_textures: Array = []
var active_foods: Array = []

func _ready():
	# Cargar todas las imágenes de ingredientes al inicio
	var dir = DirAccess.open("res://assets/pastry/ingredients")
	if dir:
		for file in dir.get_files():
			if file.ends_with(".png"):
				var path = "res://assets/pastry/ingredients/" + file
				ingredient_textures.append({
					"texture": load(path),
					"id": file.get_basename() # ej: ing_001
				})
	
	spawn_food()
	spawn_timer()

func spawn_timer():
	var t = Timer.new()
	t.wait_time = spawn_interval
	t.autostart = true
	t.one_shot = false
	add_child(t)
	t.timeout.connect(spawn_food)

func spawn_food():
	if active_foods.size() >= max_on_screen:
		return
	
	var data = ingredient_textures.pick_random()
	var food_instance = food_item_scene.instantiate()
	food_instance.setup(data["texture"], data["id"])
	
	# Empieza desde la derecha
	var start_x = get_viewport().size.x + 100
	food_instance.position = Vector2(start_x, spawn_y)
	
	add_child(food_instance)
	active_foods.append(food_instance)

func _process(delta: float) -> void:
	for food in active_foods:
		if food and is_instance_valid(food):
			food.position.x -= speed * delta
			if food.position.x < -100:
				active_foods.erase(food)
				food.queue_free()
