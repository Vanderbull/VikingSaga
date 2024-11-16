extends Label
@onready var globals = get_node("/root/Globals")

func update_text(current_warmth, max_warmth):
		text = """%d / %s""" % [globals.Health, globals.MaxHealth]
