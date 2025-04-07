extends Node2D

@onready var sensors     	= get_node("Sensors").get_children()
@onready var left_motor  	= get_node("Motors").get_node("left_motor")
@onready var right_motor  	= get_node("Motors").get_node("right_motor")

var angular_velocity = 0.0
var forward_velocity = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.get_node("Label").text = name  # automatycznie ustawia tekst na nazwę obiektu
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_input(delta)
	pass
	
		
func _physics_process(delta: float) -> void:
	move_vehicle(delta)

func handle_input(delta: float) -> void:
	# Sterowanie lewym kołem (Q - zwiększ, A - zmniejsz)
	if Input.is_action_pressed("increase_left"):  
		left_motor.add_velocity(100 * delta)
	if Input.is_action_pressed("decrease_left"):  
		left_motor.add_velocity(-100 * delta)
		
	# Sterowanie prawym kołem (E - zwiększ, D - zmniejsz)
	if Input.is_action_pressed("increase_right"):  
		right_motor.add_velocity(100 * delta)
	if Input.is_action_pressed("decrease_right"):  
		right_motor.add_velocity(-100 * delta)

			
func move_vehicle(delta_t: float) -> void:
	# left motor position and velocity
	var lP: Vector2	= left_motor.get_position()
	var lV: Vector2 = left_motor.get_velocity()
	# right motor position and velocity
	var rP: Vector2 = right_motor.get_position()
	var rV: Vector2 = right_motor.get_velocity()
	
	var center_velocity = 	rV + (lV - rV) * rP.length() / (lP - rP).length()
	
	var angular_velocity = (lV - center_velocity).cross(lP) / (lP.length() * lP.length())
	
	
	rotate(angular_velocity * delta_t)
	translate(-center_velocity.rotated(rotation) * delta_t)
	
func get_sensor_value(id: int) -> float:
	return sensors[id].get_color().get_luminance()
