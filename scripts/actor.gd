extends Node2D

@onready var environment 	= get_node("/root/Simulation/Environment")
@onready var sensors     	= get_node("Sensors").get_children()
@onready var motors  		= get_node("Motors").get_children()

var background_sprite
var background_image


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	# Pobieramy teksturę tła i jej obraz
	background_sprite = environment.get_node("./FloorSprite")
	var texture = background_sprite.texture
	background_image = texture.get_image()
	var color1 = background_image.get_pixel(214, 863)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var sensor_global_pos = global_position  # zakładając, że skrypt jest na sensorze
	var floor_color = get_floor_color(sensor_global_pos)
	# Możesz tutaj np. wypisać kolor lub wykorzystać go do sterowania zachowaniem robota:
	print("Kolor pod sensorem: ", floor_color)


# Funkcja, która zwraca kolor piksela pod daną pozycją (globalną)
func get_floor_color(sensor_global_pos: Vector2) -> Color:
	# Konwersja globalnej pozycji sensora na lokalne współrzędne tła
	var local_pos = background_sprite.to_local(sensor_global_pos)
	# Jeżeli sprite jest skalowany lub rozmiar tekstury różni się od rozmiaru sprite'a,
	# należy przeliczyć współrzędne:
	var sprite_size = background_sprite.texture.get_size()
	var node_size = background_sprite.get_scale() * sprite_size  # lub inne obliczenia zależnie od ustawień
	
	# Zakładamy, że pozycje lokalne są już w pikselach,
	# ale w razie potrzeby można przeliczyć:
	var pixel_x = int(local_pos.x)
	var pixel_y = int(local_pos.y)
	
	print(pixel_x, " : ", pixel_y)
	# Sprawdzamy, czy współrzędne mieszczą się w granicach obrazu
	if pixel_x < 0 or pixel_y < 0 or pixel_x >= background_image.get_width() or pixel_y >= background_image.get_height():
		return Color(0,0,0,0)  # np. zwracamy przezroczysty czarny, gdy poza obszarem
	
	return background_image.get_pixel(pixel_x, pixel_y)
