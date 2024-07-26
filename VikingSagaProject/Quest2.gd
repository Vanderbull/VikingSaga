extends Label


@onready var globals = get_node("/root/Globals")

func update_text():
		text = """[ ] Collect food %s / 10000
				""" % [globals.gain_quest_food(1)]
