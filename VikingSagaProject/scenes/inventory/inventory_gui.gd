extends Control

# Define signals to notify when the panel is opened or closed.
signal opened
signal closed

# Global state: whether the panel is open or not.
var isOpen: bool = false

func _ready() -> void:
	# Optionally, you could perform initialization here.
	pass

# Opens the panel:
func open() -> void:
	visible = true       # Make the panel visible.
	isOpen = true        # Update the state variable.
	emit_signal("opened")  # Emit the "opened" signal.

# Closes the panel:
func close() -> void:
	visible = false      # Hide the panel.
	isOpen = false       # Update the state variable.
	emit_signal("closed")  # Emit the "closed" signal.
