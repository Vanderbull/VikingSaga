extends Label

@export var finished: bool = false                # If quest is finished
@export var amount: int = 10000                # If quest is finished

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestWater >= amount:
		text = "[X] Collect trees %s / %d" % [globals.QuestWater, amount]
	else:
		text = "[ ] Collect trees %s / %d" % [globals.QuestWater, amount]
