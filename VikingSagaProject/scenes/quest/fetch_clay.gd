extends Label

@export var finished: bool = false                # If quest is finished
@onready var globals = get_node("/root/Globals")

func _process(delta):
	if globals.quest_clay >= globals.MAX_QUEST_CLAY:
		text = "[✓] Collect clay %s / %d" % [globals.quest_clay, globals.MAX_QUEST_CLAY]
	else:
		text = "[ ] Collect clay %s / %d" % [globals.quest_clay, globals.MAX_QUEST_CLAY]
		
func update_text():
	if globals.quest_clay >= globals.MAX_QUEST_CLAY:
		text = "[✓] Collect clay %s / %d" % [globals.quest_clay, globals.MAX_QUEST_CLAY]
	else:
		globals.gain_quest_wood(100)
		text = "[ ] Collect clay %s / %d" % [globals.quest_clay, globals.MAX_QUEST_CLAY]
