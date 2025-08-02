extends Label

@export var finished: bool = false                # If quest is finished
@onready var globals = get_node("/root/Globals")

func _process(delta):
	if globals.quest_wood >= globals.MAX_QUEST_WOOD:
		text = "[✓] Collect trees %s / %d" % [globals.quest_wood, globals.MAX_QUEST_WOOD]
	else:
		text = "[ ] Collect trees %s / %d" % [globals.quest_wood, globals.MAX_QUEST_WOOD]
	
func update_text():
	if globals.quest_wood >= globals.MAX_QUEST_WOOD:
		text = "[✓] Collect trees %s / %d" % [globals.quest_wood, globals.MAX_QUEST_WOOD]
	else:
		globals.gain_quest_trees(100)
		text = "[ ] Collect trees %s / %d" % [globals.quest_wood, globals.MAX_QUEST_WOOD]
