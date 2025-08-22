extends Node
class_name QuestManager

signal quest_completed(id: StringName)

var _completed: Dictionary = {} # id -> bool

func is_completed(id: StringName) -> bool:
	return _completed.get(id, false)

func complete(id: StringName) -> void:
	if _completed.get(id, false):
		return
	_completed[id] = true
	emit_signal("quest_completed", id)
	_show_finished_ui(id)

func _show_finished_ui(id: StringName) -> void:
	# Keep this generic so designers can swap the scene
	var ui := preload("res://UI/QuestFinished.tscn").instantiate()
	ui.set("quest_id", id) # optional if your UI needs it
	get_tree().root.add_child(ui)
