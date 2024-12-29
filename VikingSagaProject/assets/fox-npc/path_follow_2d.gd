extends PathFollow2D

@export var speed: float = 100.0  # Speed in pixels per second
var offset = 0

func _process(delta: float):
	return
	# Move along the path
	offset += speed * delta

	# Loop back when reaching the end of the path
	if offset > get_parent().curve.get_baked_length():
		offset = 0
