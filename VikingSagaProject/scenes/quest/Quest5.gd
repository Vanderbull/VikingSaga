extends Label

@export var finished: bool = false                # If quest is finished
@export var amount: int = 10                # If quest is finished

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestRoads >= amount:
		text = """[X] Build some roads %s / %s""" % [globals.QuestTrees][amount]
	else:
		text = """[ ] Build some roads %s / %s""" % [globals.QuestTrees][amount]
