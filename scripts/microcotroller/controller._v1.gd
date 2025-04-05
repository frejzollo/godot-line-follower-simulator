extends Node

# program based on amjed-ali-k code:
# https://github.com/amjed-ali-k/ESP-32-Line-Follower/blob/main/src/main.cpp

@onready var ACTOR = get_parent()
@export var HISTORY_SIZE 	= 10
@export var NO_LINE_COUNT  	= 20
@export var SENSOR_COUNT 	= 5

var left_min_speed 		= -50
var right_min_speed 	= -50
var left_max_speed 		= 255
var right_max_speed 	= 255

var sensor_values = []
var reading_history = []
var sensor_weights = [	12.5, 
						6.0,
						0.5, 
						0.1, 
						0.5,
						6.0, 
						12.5]

# PID variables
@export var Kp = 1
@export var Ki = 0.01
@export var Kd = 0 #0.1;

# deklarowanie sterowników PID dla silników
@onready var pid_left 	= PIDController.new(Kp, Ki, Kd)  	# PID dla lewego silnika
@onready var pid_right 	= PIDController.new(Kp, Ki, Kd) 	# PID dla prawego silnika

var line_error: float = 0.0
var line_threshold: float = 0.4
var no_line_count: int = 0

func read_and_calculate_error():
	var line_detected = false
	line_error = 0.0

	for i in range(SENSOR_COUNT):
		line_error += (i - (SENSOR_COUNT-1)/2) * (1-ACTOR.get_sensor_value(i)) * sensor_weights[i]
		if ACTOR.get_sensor_value(i) < line_threshold:
			line_detected = true
	#print("line_detected ", line_detected)
	#print("line_error ", line_error)
	
	if not line_detected:
		no_line_count += 1
		if no_line_count > NO_LINE_COUNT:
			line_error = find_where_last_line_went() * 50000
	else:
		no_line_count = 0

func find_where_last_line_went() -> int:
	var history_error = 0.0

	for l in range(HISTORY_SIZE - 1, -1, -1):
		for i in range(SENSOR_COUNT):
			history_error += (i - (SENSOR_COUNT-1)/2) * ACTOR.get_sensor_value(i) * sensor_weights[i] * (l / 10.0)

	return 1 if history_error > 50 else -1 if history_error < -50 else 0

func calculate_motor_speed():
	pid_left.input 	= clampf(line_error, -20, 20) / 20 * 255
	pid_right.input = clampf(-line_error, -20, 20) / 20 * 255
	#print("pid_left: ", pid_left.input)
	#print("pid_right: ", pid_right.input)
	pid_left.compute()
	pid_right.compute()
	#print("pid_left output: ", pid_left.output)
	#print("pid_right output: ", pid_right.output)

func set_motor_speed():
	var left_speed = 50 + pid_left.output
	var right_speed = 50 + pid_right.output

	ACTOR.left_motor.set_velocity(clamp(left_speed, left_min_speed, left_max_speed))
	ACTOR.right_motor.set_velocity(clamp(right_speed, right_min_speed, right_max_speed))
	
	
# something like "setup" function in arduino
func _ready() -> void:
	sensor_values.resize(SENSOR_COUNT)
	reading_history.resize(SENSOR_COUNT)
	for i in range(SENSOR_COUNT):
		reading_history[i] = []
		reading_history[i].resize(HISTORY_SIZE)

	#$Timer.start()


# something like "loop" function in arduino
func _process(delta: float) -> void:
	read_and_calculate_error()
	calculate_motor_speed()
	set_motor_speed()
