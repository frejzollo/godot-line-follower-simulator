extends ColorSensor
# extends "res://scripts/scripts2D/color_sensor.gd"
class_name LineSensor

# Called when the node enters the scene tree for the first time.
func _ready():
	read_frequency = 0.1
	noise_intensity = 0.01
	
	r_weights =	[[1,1,1],
				 [1,2,1],
				 [1,1,1]]
						
	g_weights =	[[1,1,1],
				 [1,2,1],
				 [1,1,1]]
						
	b_weights =	[[1,1,1],
				 [1,2,1],
				 [1,1,1]]
	super()

func get_color() -> Color:
	return current_color
