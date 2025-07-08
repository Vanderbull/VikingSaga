extends Control

@onready var globals = get_node("/root/Globals")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_pressed():
	hide()
	print("pressing the matter")
	globals.QuestWater = 0
	globals.QuestFood = 0
	globals.QuestTrees = 0
	globals.QuestClay = 0
	globals.QuestRoads = 0
	pass # Replace with function body.
