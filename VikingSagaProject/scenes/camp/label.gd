extends Label

func _ready():
	# Set the label's pivot offset to its center
	# This ensures that any scaling or rotation happens from the middle
	set_pivot_offset(size / 2.0)

	# Center the label within its parent (the Control node)
	# This automatically sets the anchors and margins for perfect centering
	set_anchors_preset(Control.PRESET_CENTER)
	
	# You can uncomment and use the following line if you want to start the
	# animation from the script as well.
	# get_node("../AnimationPlayer").play("Sleeping")
