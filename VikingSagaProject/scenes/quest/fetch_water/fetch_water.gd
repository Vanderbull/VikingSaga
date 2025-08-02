extends Label

@export var finished: bool = false                # If quest is finished
@onready var globals = get_node("/root/Globals")

func _process(delta):
	if globals.quest_water >= globals.MAX_QUEST_WATER:
		text = "[✓] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
	else:
		text = "[ ] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
		
func update_text():
	if globals.quest_water >= globals.MAX_QUEST_WATER:
		text = "[✓] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
	else:
		globals.gain_quest_water(100)
		text = "[ ] Collect water %s / %d" % [globals.quest_water, globals.MAX_QUEST_WATER]
