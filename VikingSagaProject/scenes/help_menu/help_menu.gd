# This script should be attached to the root node of your branch scene,
# such as a Panel or Control node that represents the pause menu.

extends CanvasLayer

# A boolean to check if the scene is active and should respond to input.
# This helps prevent the scene from handling input when it's not visible or paused.
var is_active = false

func _ready():
	# Set a flag to indicate the scene is ready and active.
	is_active = true
	# It's good practice to pause the game when the menu appears.
	get_tree().paused = true

func _unhandled_input(event: InputEvent):
	# Check if the scene is active and if the pressed event is the "ui_cancel" action.
	# "ui_cancel" is the default action for the Escape key in Godot.
	if is_active and event.is_action_pressed("ui_cancel"):
		# Unpause the game.
		get_tree().paused = false
		
		# There are two main ways to "hide" the scene:
		
		# Option 1: Hide the node and keep it in the scene tree.
		# This is useful if you want to show it again later without reloading.
		# hide()
		
		# Option 2 (Recommended for temporary scenes like a pause menu):
		# Remove the scene from the tree and free its memory.
		# This is generally cleaner for temporary pop-up menus.
		queue_free()
		
		# Mark the scene as inactive to stop handling input after it's hidden.
		is_active = false
