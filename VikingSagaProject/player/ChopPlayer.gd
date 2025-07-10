extends AudioStreamPlayer
func _ready():
	pass # Replace with function body.
# Function to check if the audio is playing
func is_audio_playing() -> bool:
	return is_playing()
func _on_finished():
	pass # Replace with function body.
