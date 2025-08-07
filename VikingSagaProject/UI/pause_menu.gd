extends Control
@export var game_manager : GameManager
@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound
func _ready():
	$VersionNumber.text = Version.get_full_version_string()
	game_manager.connect("toggle_game_paused",_on_game_manager_toggle_game_paused)
func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
func _on_game_manager_toggle_game_paused(is_paused : bool):
	if(is_paused):
		var action_buttons = %Player.find_child("ActionButtons")
		action_buttons = %Player.get_child(12)
		action_buttons.hide()
		$"../../world".hide()
		$"../../InGameCanvasLayer".hide()
		%Quests.hide()
		$"../../Interface".hide()
		%ActionButtons.hide()
		$"../../TileInfoWindow".hide()
		show()
	else:
		%ActionButtons.show()
		$"../../world".show()
		$"../../InGameCanvasLayer".show()
		%Quests.show()
		$"../../Interface".show()
		$"../../TileInfoWindow".show()
		%ActionButtons.hide()
		hide()
func _on_load_button_mouse_entered():
	hover_sound.play()
func _on_load_button_pressed():
	click_sound.play()
func _on_new_game_button_pressed() -> void:
	click_sound.play()
	await click_sound.finished  # Wait until the sound finishes playing
	game_manager.game_paused = false
func _on_new_game_button_mouse_entered() -> void:
	hover_sound.play()
func _on_settings_button_mouse_entered():
	hover_sound.play()
func _on_settings_button_pressed():
	click_sound.play()
func _on_exit_button_mouse_entered():
	hover_sound.play()
func _on_exit_button_pressed():
	click_sound.play()
	await click_sound.finished  # Wait until the sound finishes playing
	get_tree().quit()
