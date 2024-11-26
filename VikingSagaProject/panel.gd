extends Panel

func _process(delta: float) -> void:
	# Reset size to match children dynamically
	if get_child_count() > 0:
		var content_size = Vector2(0, 0)
		for child in get_children():
			if child is Control:  # Only consider Control nodes
				content_size.x = max(content_size.x, child.size.x)
				content_size.y += child.size.y
		custom_minimum_size = content_size
