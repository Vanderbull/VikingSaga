extends Label


@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestFood >= 10000:
		text = """[X] Collect food %s / 10000""" % [globals.gain_quest_food(1)]
	else:
		text = """[ ] Collect food %s / 10000""" % [globals.gain_quest_food(1)]
