extends Label

@export var finished: bool = false                # If quest is finished
@export var amount: int = 10000                # If quest is finished

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestFood >= amount:
		text = "[X] Collect food %s / %d" % [globals.QuestFood, amount]
	else:
		text = "[ ] Collect food %s / %d" % [globals.QuestFood, amount]
