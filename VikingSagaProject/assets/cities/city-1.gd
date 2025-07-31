extends Node2D
var current_state = IDLE
var start_pos = Vector2(0,0)  # Variable to store the starting position
enum {
	IDLE
}
const TIMER_WAIT_TIMES = [0.5, 1, 1.5]

func _ready():
	randomize()
	#$Timer.start()
	# Store the initial position of the NPC
	start_pos = position

func _process(_delta):
	# Play the appropriate animation based on the current state
	if current_state == IDLE:
		pass
	match current_state:
		IDLE:
			pass
			
func choose(array):
	var temp_array = array.duplicate()  # Duplicate the array to make it writable
	temp_array.shuffle()  # Shuffle the duplicated array
	return temp_array.front()  # Return the first element of the shuffled array
	
# Timer timeout function to handle state changes
func _on_timer_timeout():
	# Set a random wait time for the timer
	#$Timer.wait_time = choose(TIMER_WAIT_TIMES)
	# Randomly choose the next state for the NPC (either IDLE or NEW_DIR)
	current_state = choose([IDLE])
	# Restart the timer
	#$Timer.start()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	$CanvasLayer/Label.show()
	var fetch_food_node = get_node("/root/GameManager/Quests/Control/Panel/VBoxContainer/fetch_food")
	if Globals.quest_food < Globals.MAX_QUEST_FOOD:
		fetch_food_node.text = "[ ] Fetch food %s / %d" % [Globals.quest_food, Globals.MAX_QUEST_FOOD]
	else:
		fetch_food_node.text = "[X] Fetch food %s / %d" % [Globals.quest_food, Globals.MAX_QUEST_FOOD]
	var fetch_water_node = get_node("/root/GameManager/Quests/Control/Panel/VBoxContainer/fetch_water")
	if Globals.quest_water < Globals.MAX_QUEST_WATER:
		fetch_water_node.text = "[ ] Fetch water %s / %d" % [Globals.quest_water, Globals.MAX_QUEST_WATER]
	else:
		fetch_water_node.text = "[X] Fetch water %s / %d" % [Globals.quest_water, Globals.MAX_QUEST_WATER]
	var fetch_wood_node = get_node("/root/GameManager/Quests/Control/Panel/VBoxContainer/fetch_wood")
	if Globals.quest_wood < Globals.MAX_QUEST_WOOD:
		fetch_wood_node.text = "[ ] Fetch wood %s / %d" % [Globals.quest_wood, Globals.MAX_QUEST_WOOD]
	else:
		fetch_water_node.text = "[X] Fetch wood %s / %d" % [Globals.quest_wood, Globals.MAX_QUEST_WOOD]
	var fetch_clay_node = get_node("/root/GameManager/Quests/Control/Panel/VBoxContainer/fetch_clay")
	if Globals.quest_clay < Globals.MAX_QUEST_CLAY:
		fetch_clay_node.text = "[ ] Fetch clay %s / %d" % [Globals.quest_clay, Globals.MAX_QUEST_CLAY]
	else:
		fetch_clay_node.text = "[X] Fetch clay %s / %d" % [Globals.quest_clay, Globals.MAX_QUEST_CLAY]
		
func _on_area_2d_area_exited(_area: Area2D) -> void:
	$CanvasLayer/Label.hide()
