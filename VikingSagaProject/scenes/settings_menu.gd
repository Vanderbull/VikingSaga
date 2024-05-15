extends Control

func _ready():
	$AudioStreamPlayer
	DisplayServer.window_get_size()
	get_viewport().get_visible_rect().size
	$VBoxContainer/Resolution.text = "Resolution: " + str(DisplayServer.window_get_size()) #"Resolution: 1920x1080"
	
	$VBoxContainer/Volume.text = "Volume: " + str(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))

func _process(delta):
	$VBoxContainer/Resolution.text = "Resolution: " + str(DisplayServer.window_get_size()) #"Resolution: 1920x1080"
	$VBoxContainer/Volume.text = "Volume: " + str(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	$VBoxContainer/Mixrate.text = "Mixrate: " + str(AudioServer.get_mix_rate())
		
