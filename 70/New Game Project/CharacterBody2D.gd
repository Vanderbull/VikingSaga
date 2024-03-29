extends CharacterBody2D

const SPEED = 300.0
const ACCEL = 2

var input: Vector2

func get_input():
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input.normalized()
	
func _physics_process(delta):
	var playerInput = get_input()
	velocity = lerp(velocity, playerInput * SPEED, delta * ACCEL)
	move_and_slide()
