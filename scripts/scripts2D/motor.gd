extends Node2D

class_name Motor

@export var max_abs_velocity 		=  	100.0
@export var min_abs_velocity 		= 	10.0
@export var velocity: Vector2	= Vector2(0.0, 0.0)

func add_velocity(dV: float) -> void:
	velocity.y += dV
	if velocity.y > max_abs_velocity:
		velocity.y = max_abs_velocity
	elif velocity.y < -max_abs_velocity:
		velocity.y = -max_abs_velocity

func get_velocity() -> Vector2:
	if abs(velocity.y) >= min_abs_velocity:
		return velocity
	return Vector2(0.0, 0.0)
