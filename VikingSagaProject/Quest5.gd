extends Label


@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestTrees >= 10000:
		text = """[X] Collect trees %s / 10000""" % [globals.gain_quest_trees(0)]
	else:
		text = """[ ] Collect trees %s / 10000""" % [globals.gain_quest_trees(1000)]

