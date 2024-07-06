extends Control

@export var game_manager : GameManager

func _ready():
	verify_save_directory(game_manager.playerData.save_file_path)
	hide()
	game_manager.connect("toggle_game_paused",_on_game_manager_toggle_game_paused)
	

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
	
func _process(_delta):
	pass
	

func _on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		#print_debug("PAUSED")
		$"../../world".set_visible(false)
		$"../../InGameCanvasLayer".set_visible(false)
		show()
	else:
		hide()
		#print_debug("MOVE")
		

func _on_resume_button_pressed():
	#print_debug("RESUME PRESSED")
	game_manager.game_paused = false
	$"../../world".set_visible(true)
	$"../../InGameCanvasLayer".set_visible(true)


func _on_exit_button_pressed():
	get_tree().quit()


func _on_save_button_pressed():
	print("SAVE PRESSED")
	print(OS.get_user_data_dir())
	ResourceSaver.save(game_manager.playerData, game_manager.playerData.save_file_path + game_manager.playerData.save_file_name)
	game_manager.playerData.save("user://save/tilemap2.tres",$"../../world/TileMap2")
	

func _on_load_button_pressed():
	print("LOAD PRESSED")
	if ResourceLoader.exists(game_manager.playerData.save_file_path + game_manager.playerData.save_file_name):
		game_manager.playerData = ResourceLoader.load(game_manager.playerData.save_file_path + game_manager.playerData.save_file_name).duplicate(true)
		$"../../world/TileMap/Player".position = game_manager.playerData.player_position
		game_manager.playerData.LoadSaveGame = true
		game_manager.playerData.load("user://save/tilemap2.tres",$"../../world/TileMap2")
		#game_manager.playerData.moisture = moisture.seed
		#game_manager.playerData.temperature = temperature.seed
		#game_manager.playerData.altitude = altitude.seed
		#$"../../InGameCanvasLayer/Trees".text = str(game_manager.playerData.health)
	return null
