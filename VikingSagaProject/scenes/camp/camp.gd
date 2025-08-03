extends Control

@onready var label = $Label

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
