extends Label

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestWater >= 10000:
		text = """[X] Collect water %s / 10000""" % [globals.gain_quest_water(0)]
	else:
		text = """[ ] Collect water %s / 10000""" % [globals.gain_quest_water(1000)]
