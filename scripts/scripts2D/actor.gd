extends RigidBody2D

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
	var sensor_global_pos = global_position 
	
	for sensor in sensors:
		print("sensor ", sensor.name, " : ", sensor.get_color())
