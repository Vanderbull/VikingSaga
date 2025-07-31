extends Label

@export var finished: bool = false                # If quest is finished
@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.quest_water >= globals.MAX_QUEST_WATER:
		text = "[✓] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
	else:
		text = "[ ] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
