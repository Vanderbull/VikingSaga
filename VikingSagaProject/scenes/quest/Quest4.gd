extends Label

@export var finished: bool = false                # If quest is finished
@export var amount: int = 10000                # If quest is finished

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestClay >= amount:
		text = "[X] Collect clay %s / %d" % [globals.QuestClay, amount]
	else:
		text = "[ ] Collect clay %s / %d" % [globals.QuestClay, amount]
