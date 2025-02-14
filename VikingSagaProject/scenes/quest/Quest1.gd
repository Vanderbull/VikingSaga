extends Label

@onready var globals = get_node("/root/Globals")

func update_text():
	if globals.QuestWater >= 10000:
		text = """[X] Collect water %s / 10000""" % [globals.QuestWater]
	else:
		text = """[ ] Collect water %s / 10000""" % [globals.QuestWater]

func _ready():
	pass
	# Connect the update_text function to a signal if needed, e.g., for updating every frame or on specific events.
