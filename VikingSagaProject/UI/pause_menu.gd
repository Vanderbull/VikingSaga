extends Control

@export var game_manager : GameManager

# Reference to the AudioStreamPlayer node
@onready var click_sound = $Panel/VBoxContainer/SaveButton/AudioStreamPlayer
@onready var hover_sound = $HoverSound

func _ready():
	print("Getting the mainmenu _ready...")
	verify_save_directory(game_manager.playerData.save_file_path)
	game_manager.connect("toggle_game_paused",_on_game_manager_toggle_game_paused)

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

# Show or hides the main menu	
func _on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		print("show")
		$"../../world".hide()
		$"../../InGameCanvasLayer".hide()
		$"../../Quests".hide()
		$"../../Interface".hide()
		$"../../TileInfoWindow".hide()
		show()
	else:
		print("hide")
		$"../../world".show()
		$"../../InGameCanvasLayer".show()
		$"../../Quests".show()
		$"../../Interface".show()
		$"../../TileInfoWindow".show()
		hide()

func _on_resume_button_mouse_entered():
	hover_sound.play()
func _on_resume_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait until the sound finishes playing
	game_manager.game_paused = false

func _on_exit_button_mouse_entered():
	hover_sound.play()
func _on_exit_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait until the sound finishes playing
	get_tree().quit()

func _on_save_button_mouse_entered():
	hover_sound.play()
func _on_save_button_pressed():
	click_sound.play()
	print("SAVE PRESSED")
	print(OS.get_user_data_dir())
	ResourceSaver.save(game_manager.playerData, game_manager.playerData.save_file_path + game_manager.playerData.save_file_name)
	game_manager.playerData.save("user://save/tilemap2.tres",$"../../world/TileMap2")

func _on_load_button_mouse_entered():
	hover_sound.play()
func _on_load_button_pressed():
	click_sound.play()
	print("LOAD PRESSED")
	if ResourceLoader.exists(game_manager.playerData.save_file_path + game_manager.playerData.save_file_name):
		game_manager.playerData = ResourceLoader.load(game_manager.playerData.save_file_path + game_manager.playerData.save_file_name).duplicate(true)
		$"../../world/TileMap/Player".position = game_manager.playerData.player_position
		game_manager.playerData.LoadSaveGame = true
		game_manager.playerData.load("user://save/tilemap2.tres",$"../../world/TileMap2")
	return null

func _on_settings_button_mouse_entered():
	hover_sound.play()
func _on_settings_button_pressed():
	click_sound.play()
