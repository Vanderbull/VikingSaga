extends Label

@export var finished: bool = false                # If quest is finished
@export var amount: int = 10                # If quest is finished

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestRoads >= amount:
		text = "[✓] Build some roads %s / %d" % [globals.QuestRoads, amount]
	else:
		text = "[ ] Build some roads %s / %d" % [globals.QuestRoads, amount]
