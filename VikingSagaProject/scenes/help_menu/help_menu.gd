extends CanvasLayer

@onready var code_edit = $Control/CodeEdit
# A boolean to check if the scene is active and should respond to input.
# This helps prevent the scene from handling input when it's not visible or paused.
var is_active = false

func _ready():
	# Populate the controls section with key bindings
	populate_controls()
		
	# Set a flag to indicate the scene is ready and active.
	is_active = true
	# It's good practice to pause the game when the menu appears.
	get_tree().paused = true
	

# This function iterates through the InputMap and populates the CodeEdit node.
func populate_controls():
	# Build a list of strings to be joined later
	var key_bindings_text = []
	
	# Get all actions defined in the InputMap
	var actions = InputMap.get_actions()
	
	for action in actions:
		# Filter out Godot's built-in UI actions.
		if action.begins_with("ui_"):
			continue
		# Get all events associated with the current action
		var events = InputMap.action_get_events(action)
		
		# Collect all event names for the current action
		var event_names = []
		for event in events:
			var event_text = ""
			
			# Use as_text() to get a reliable string representation for any input event.
			if event is InputEventKey:
				event_text = event.as_text()
			elif event is InputEventMouseButton:
				event_text = "Mouse Button %s" % event.button_index
			elif event is InputEventJoypadButton:
				event_text = "Joypad Button %s" % event.button_index
			elif event is InputEventJoypadMotion:
				event_text = "Joypad Axis %s" % event.axis
			
			if not event_text.is_empty():
				event_names.append(event_text)
		
		# Format the action name and join the event names
		var action_name = action.capitalize().replace("_", " ") + ":"
		var bindings_string = ""
		if not event_names.is_empty():
			bindings_string = ", ".join(event_names)
		else:
			bindings_string = "No events configured"
		
		key_bindings_text.append("%-20s%s" % [action_name, bindings_string])
	
	# Join the list into a single string with newlines and set the CodeEdit's text
	code_edit.text = "\n".join(key_bindings_text)


#func _unhandled_input(event: InputEvent):
	## Check if the scene is active and if the pressed event is the "ui_cancel" action.
	## "ui_cancel" is the default action for the Escape key in Godot.
	#if is_active and event.is_action_pressed("ui_cancel"):
		## Unpause the game.
		#get_tree().paused = false
		#
		## There are two main ways to "hide" the scene:
		#
		## Option 1: Hide the node and keep it in the scene tree.
		## This is useful if you want to show it again later without reloading.
		## hide()
		#
		## Option 2 (Recommended for temporary scenes like a pause menu):
		## Remove the scene from the tree and free its memory.
		## This is generally cleaner for temporary pop-up menus.
		#queue_free()
		#
		## Mark the scene as inactive to stop handling input after it's hidden.
		#is_active = false
