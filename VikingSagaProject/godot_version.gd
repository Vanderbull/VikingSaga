extends Label
@onready var globals = get_node("/root/Globals")

func update_text():
	text = "Godot version:  %s" % globals.godot_version
