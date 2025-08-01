extends Control
@export var game_manager : GameManager
@onready var click_sound = $Panel/VBoxContainer/SaveButton/AudioStreamPlayer
@onready var hover_sound = $HoverSound
func _ready():
	$VersionNumber.text = Version.get_full_version_string()
	verify_save_directory(game_manager.playerData.save_file_path)
	game_manager.connect("toggle_game_paused",_on_game_manager_toggle_game_paused)
func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
# Show or hides the main menu	
func _on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		#print("show")
		var action_buttons = %Player.find_child("ActionButtons")
		#print("action_buttons: %i", action_buttons.get_index())
		action_buttons = %Player.get_child(12)
		action_buttons.hide()
		$"../../world".hide()
		$"../../InGameCanvasLayer".hide()
		%Quests.hide() #$"../../Quests".hide()
		$"../../Interface".hide()
		#$"../../TileInfoWindow".hide()
		show()
	else:
		#print("hide")
		%ActionButtons.show()
		$"../../world".show()
		$"../../InGameCanvasLayer".show()
		%Quests.show() #$"../../Quests".show()
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
	ResourceSaver.save(game_manager.playerData, game_manager.playerData.save_file_path + game_manager.playerData.save_file_name)
	game_manager.playerData.save("user://save/tilemap2.tres",$"../../world/TileMap2")
func _on_load_button_mouse_entered():
	hover_sound.play()
func _on_load_button_pressed():
	click_sound.play()
func _on_settings_button_mouse_entered():
	hover_sound.play()
func _on_settings_button_pressed():
	click_sound.play()
