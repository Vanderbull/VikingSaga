extends Label

@export var finished: bool = false                # If quest is finished
@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.quest_food >= globals.MAX_QUEST_FOOD:
		text = "[✓] Collect food %s / %d" % [globals.quest_food, globals.MAX_QUEST_FOOD]
	else:
		text = "[ ] Collect food %s / %d" % [globals.quest_food, globals.MAX_QUEST_FOOD]
