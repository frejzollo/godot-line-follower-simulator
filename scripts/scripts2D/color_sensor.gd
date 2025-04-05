extends Node2D

class_name ColorSensor

@export var read_frequency:  float = 0.1  # Częstotliwość odczytu w sekundach (np. 10 razy na sekundę)
@export var noise_intensity: float = 0.0  # Intensywność szumu
var background_image: Image = null
var background_sprite: Sprite2D
var current_color: Color = Color(0, 0, 0, 1)  # Domyślnie czarny

# Macierze wag - klasy potomne mogą je nadpisywać
var r_weights: Array = [[1]]
var g_weights: Array = [[1]]
var b_weights: Array = [[1]]

# Called when the node enters the scene tree for the first time.
func _ready():
	var environment = get_node("/root/Simulation/Environment")
	background_sprite = environment.get_node("./FloorSprite")
	var texture = background_sprite.texture
	background_image = texture.get_image()
	
	# Uruchamiamy cykliczne odczytywanie koloru
	start_reading()
	
func start_reading():
	# Uruchamiamy Timer do cyklicznego odczytu koloru
	var timer = Timer.new()
	timer.wait_time = read_frequency
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", read_color_from_environment.bind())
	add_child(timer)

func read_color_from_environment():
	if background_image == null:
		return
	
	# Pobieramy pozycję sensora w globalnych współrzędnych
	var sensor_global_pos = global_position
	
	# Konwertujemy na lokalne współrzędne względem background_sprite
	var local_pos = background_sprite.to_local(sensor_global_pos)
	
	# Zamiana na współrzędne obrazu
	var sprite_size = background_sprite.texture.get_size()
	var pixel_x = int(local_pos.x)
	var pixel_y = int(local_pos.y)
	
	# Sprawdzamy, czy współrzędne są w zakresie obrazu
	current_color = get_weighted_average_color(pixel_x, pixel_y)
	update_sprite_color()

func update_sprite_color() -> void:
	$Sprite2D.modulate = current_color
	
func get_weighted_average_color(x: int, y: int) -> Color:
	var r = 0.0
	var g = 0.0
	var b = 0.0
	var total_weight_r = 0.0
	var total_weight_g = 0.0
	var total_weight_b = 0.0
	
	var radius = r_weights[0].size()/2

	var size = 2 * radius + 1  # N x N macierz

	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var px = x + dx
			var py = y + dy
			var index_x = dx + radius
			var index_y = dy + radius

			if px >= 0 and py >= 0 and px < background_image.get_width() and py < background_image.get_height():
				var col = background_image.get_pixel(px, py)
				var weight_r = r_weights[index_x][index_y]
				var weight_g = g_weights[index_x][index_y]
				var weight_b = b_weights[index_x][index_y]

				r += col.r * weight_r
				g += col.g * weight_g
				b += col.b * weight_b

				total_weight_r += weight_r
				total_weight_g += weight_g
				total_weight_b += weight_b

	# Normalizowanie kolorów, aby wartości były w zakresie 0-1
	if total_weight_r > 0: r /= total_weight_r
	if total_weight_g > 0: g /= total_weight_g
	if total_weight_b > 0: b /= total_weight_b

	return apply_noise(Color(r, g, b))
	
func apply_noise(color: Color) -> Color:
	var noise_r = randf_range(-noise_intensity, noise_intensity)
	var noise_g = randf_range(-noise_intensity, noise_intensity)
	var noise_b = randf_range(-noise_intensity, noise_intensity)

	return Color(
		clamp(color.r + noise_r, 0.0, 1.0),
		clamp(color.g + noise_g, 0.0, 1.0),
		clamp(color.b + noise_b, 0.0, 1.0)
	)
	
func get_color() -> Color:
	return current_color
