extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Function to check if the audio is playing
func is_audio_playing() -> bool:
	return is_playing()

func _on_finished():
	print("Audio has finished playing.")
	pass # Replace with function body.
