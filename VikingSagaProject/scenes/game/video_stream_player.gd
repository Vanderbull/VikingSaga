extends VideoStreamPlayer

func _ready():
	# Connect the 'finished' signal to the '_on_video_finished' method
	finished.connect(_on_video_finished)

# Called when the video finishes playing
func _on_video_finished():
	# Stop the video and hide the player (or remove it entirely)
	stop()
	hide()
