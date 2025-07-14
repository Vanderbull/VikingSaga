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
	Globals.QuestFood -= 1
	Globals.QuestWater -= 1
	var fetch_food_node = get_node("/root/GameManager/Quests/Control/Panel/VBoxContainer/fetch_food")
	if Globals.QuestFood < 10000:
		fetch_food_node.text = "[ ] Fetch food %s / %d" % [Globals.QuestFood, 10000]
	else:
		fetch_food_node.text = "[X] Fetch food %s / %d" % [Globals.QuestFood, 10000]
	var fetch_water_node = get_node("/root/GameManager/Quests/Control/Panel/VBoxContainer/fetch_water")
	if Globals.QuestWater < 10000:
		fetch_water_node.text = "[ ] Fetch water %s / %d" % [Globals.QuestWater, 10000]
	else:
		fetch_water_node.text = "[X] Fetch water %s / %d" % [Globals.QuestWater, 10000]
	pass # Replace with function body.


func _on_area_2d_area_exited(_area: Area2D) -> void:
	$CanvasLayer/Label.hide()
	pass # Replace with function body.
