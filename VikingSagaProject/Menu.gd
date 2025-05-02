extends Control

@onready var VideoStreamer = $VideoStreamPlayer
@onready var AudioStreamer = %AudioStreamPlayer #$AudioStreamPlayer

func _ready():
	VideoStreamer.z_index = 1
	
func _on_play_pressed():
	$Play/Click.play()
	await get_tree().create_timer(0.02).timeout
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_options_pressed():
	$Options/Click.play()
	await get_tree().create_timer(0.02).timeout
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_quit_pressed():
	$Quit/Click.play()
	get_tree().quit()

func _on_video_stream_player_finished():
	#print_debug("FINSHIED")
	AudioStreamer.play()

func _on_audio_stream_player_ready():
	pass
