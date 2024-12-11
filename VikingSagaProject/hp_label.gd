extends Label
@onready var globals = get_node("/root/Globals")

func update_text(_current_warmth, _max_warmth):
		text = """%d / %s""" % [globals.Health, globals.MaxHealth]
