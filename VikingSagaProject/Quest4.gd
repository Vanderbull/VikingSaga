extends Label


@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestClay >= 10000:
		text = """[X] Collect clay %s / 10000""" % [globals.QuestClay]
	else:
		text = """[ ] Collect clay %s / 10000""" % [globals.QuestClay]
