extends Control

@onready var label = $Label

var scene_timer: SceneTreeTimer

func _ready():
	# Get the size of the viewport (the screen)
	var viewport_size = get_viewport_rect().size
	
	# Get the size of the label
	var label_size = label.size
	
	# Calculate the center position
	var center_pos_x = (viewport_size.x - label_size.x) / 2
	var center_pos_y = (viewport_size.y - label_size.y) / 2
	
	# Set the label's position
	label.position = Vector2(center_pos_x, center_pos_y)
	# Get the AnimationPlayer node
	var animation_player = $Label/AnimationPlayer
	
	# Play the "Sleeping" animation
	animation_player.play("sleeping")
	# Start a timer to quit the game after a few seconds
	scene_timer = get_tree().create_timer(3.0) # 3-second delay
	await scene_timer.timeout
	_on_timer_timeout()
	
@export var previous_scene_path: String = "res://scenes/game/game.tscn"

func _on_timer_timeout():
	# Make sure to unpause the game before changing the scene.
	get_tree().paused = false
	# Replace "res://path/to/your/previous_scene.tscn" with the actual path
	# of the scene you want to go back to.
	var error = get_tree().change_scene_to_file(previous_scene_path)
	# Check if there was an error during the scene change
	if error != OK:
		print("Error changing scene! Code: ", error)
		print("Is the path correct? Path provided: ", previous_scene_path)
