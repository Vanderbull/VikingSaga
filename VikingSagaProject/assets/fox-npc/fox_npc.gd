extends CharacterBody2D

@onready var globals = get_node("/root/Globals")
const SPEED = 30.0
var is_active = false
var current_state = IDLE
var dir = Vector2.RIGHT
var start_pos = Vector2(0,0)  # Variable to store the starting position
enum {
	IDLE,
	NEW_DIR,
	MOVE
}
const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
const TIMER_WAIT_TIMES = [0.5, 1, 1.5]

func _ready():
	randomize()
	$Timer.start()
	# Store the initial position of the NPC
	start_pos = position

func _process(delta):
	# Play the appropriate animation based on the current state
	if is_active:
		if current_state == IDLE:
			$AnimatedSprite2D.play("idle")
		elif current_state == MOVE:
			$AnimatedSprite2D.play("walk")
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose(DIRECTIONS)
			MOVE:
				move(delta)
	else:
		current_state == IDLE
			
func move(delta):
	position += dir * SPEED * delta
	# Reference the AnimatedSprite2D node
	var animated_sprite = $AnimatedSprite2D
	# Check if the AnimatedSprite2D node is valid before accessing it
	if animated_sprite:
		# Flip the sprite based on movement direction
		if dir.x == 1:
			animated_sprite.flip_h = false
		elif dir.x == -1:
			animated_sprite.flip_h = true

func choose(array):
	var temp_array = array.duplicate()  # Duplicate the array to make it writable
	temp_array.shuffle()  # Shuffle the duplicated array
	return temp_array.front()  # Return the first element of the shuffled array
	
# Timer timeout function to handle state changes
func _on_timer_timeout():
	# Set a random wait time for the timer
	$Timer.wait_time = choose(TIMER_WAIT_TIMES)
	# Randomly choose the next state for the NPC (either IDLE or NEW_DIR)
	current_state = choose([IDLE, NEW_DIR,MOVE])
	# Restart the timer
	$Timer.start()

func _on_animal_detection_area_area_entered(area: Area2D) -> void:
	# Check if the Area2D itself is in the "Npc" group (if you added NPCDetectionArea to "Npc" group)
	if area.is_in_group("Animal"):
		print("Animal's detection area entered!")
		# You can then get the root npc node:
		var animal_root = area.get_parent() # Or area.owner if Npc scene is instanced and NPCDetectionArea is its direct child
		if animal_root.is_in_group("Animal"): # Double check if the parent is also the npc root
			print("Confirmed: The actual Animal root node is also detected!")
			# Do npc-specific actions here
			pass
	pass # Replace with function body.
	
# This function is called when the VisibleOnScreenNotifier2D's bounding box enters the screen.
func _on_visible_on_screen_notifier_2d_screen_entered():
	is_active = true
	print("Fox entered the screen, activating.")

# This function is called when the VisibleOnScreenNotifier2D's bounding box exits the screen.
func _on_visible_on_screen_notifier_2d_screen_exited():
	is_active = false
	# Stop the enemy completely when it's off-screen
	velocity = Vector2.ZERO
	print("Fox exited the screen, deactivating.")
