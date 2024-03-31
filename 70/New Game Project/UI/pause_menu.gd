extends Control

@export var game_manager : GameManager

func _ready():
	verify_save_directory(game_manager.save_file_path)
	hide()
	game_manager.connect("toggle_game_paused",_on_game_manager_toggle_game_paused)
	

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
	
func _process(_delta):
	pass
	

func _on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		print("PAUSED")
		show()
	else:
		hide()
		

func _on_resume_button_pressed():
	print("RESUME PRESSED")
	game_manager.game_paused = false


func _on_exit_button_pressed():
	get_tree().quit()


func _on_save_button_pressed():
	print("SAVE PRESSED")
	print(OS.get_user_data_dir())
	ResourceSaver.save(game_manager.playerData, game_manager.save_file_path + game_manager.save_file_name)
	

func _on_load_button_pressed():
	print("LOAD PRESSED")
	if ResourceLoader.exists(game_manager.save_file_path + game_manager.save_file_name):
		game_manager.playerData = ResourceLoader.load(game_manager.save_file_path + game_manager.save_file_name).duplicate(true)
		$"../../InGameCanvasLayer/Trees".text = str(game_manager.playerData.health)
	return null
