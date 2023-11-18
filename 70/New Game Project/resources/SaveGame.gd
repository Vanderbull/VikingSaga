class_name SaveGame
extends Resource

const  SAVE_GAME_PATH := "user://save.tres"

@export var version := 1

func write_savegame():
	ResourceSaver.save(self, SAVE_GAME_PATH)
