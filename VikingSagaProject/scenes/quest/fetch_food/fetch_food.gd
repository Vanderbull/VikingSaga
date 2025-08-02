extends Label

@export var finished: bool = false                # If quest is finished
@onready var globals = get_node("/root/Globals")

func _process(delta):
	if globals.quest_food >= globals.MAX_QUEST_FOOD:
		text = "[✓] Collect food %s / %d" % [globals.quest_food, globals.MAX_QUEST_FOOD]
	else:
		text = "[ ] Collect food %s / %d" % [globals.quest_food, globals.MAX_QUEST_FOOD]
		
func update_text():
	if globals.quest_food >= globals.MAX_QUEST_FOOD:
		text = "[✓] Collect food %s / %d" % [globals.quest_food, globals.MAX_QUEST_FOOD]
	else:
		globals.gain_quest_food(100)
		text = "[ ] Collect food %s / %d" % [globals.quest_food, globals.MAX_QUEST_FOOD]
