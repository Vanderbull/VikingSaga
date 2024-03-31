extends Node

class_name GameManager

signal toggle_game_paused(is_paused : bool)
signal toggle_quest_paused(is_paused : bool)

var _save: SaveGame

var save_file_path = "user://save/"
var save_file_name = "PlayerSave.tres"

var playerData = PlayerData.new()

var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused",game_paused)

var quest_paused : bool = false:
	get:
		return quest_paused
	set(value):
		quest_paused = value
		get_tree().paused = quest_paused
		emit_signal("toggle_quest_paused",quest_paused)
		
func _input(event : InputEvent):
	if(event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused
	if(event.is_action_pressed("ui_home")):
		quest_paused = !quest_paused
