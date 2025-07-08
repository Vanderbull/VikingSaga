extends Label

@export var finished: bool = false                # If quest is finished
@export var amount: int = 10000                # If quest is finished

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestWater >= amount:
		text = """[X] Collect water %s / %s""" % [globals.QuestWater][amount]
	else:
		text = """[ ] Collect water %s / %s""" % [globals.QuestWater][amount]
