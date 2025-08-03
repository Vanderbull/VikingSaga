extends Control

func _ready():
	# Start a timer to quit the game after a few seconds
	var timer = get_tree().create_timer(3.0) # 3-second delay
	timer.timeout.connect(get_tree().quit)
