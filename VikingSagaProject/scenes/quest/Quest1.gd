extends Label

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestWater >= 10000:
		text = """[X] Collect water %s / 10000""" % [globals.QuestWater]
	else:
		text = """[ ] Collect water %s / 10000""" % [globals.QuestWater]
