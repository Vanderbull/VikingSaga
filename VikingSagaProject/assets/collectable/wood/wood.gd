extends Area2D
@export var value: int = 1 # How much the coin is worth

func _ready():
	pass
	# Connect the signal when the coin is ready
	#body_entered.connect(_on_body_entered)

func _on_body_entered(body: CharacterBody2D) -> void:
	# Check if the colliding body is the player
	# It's good practice to use groups for identification
	if body.is_in_group("Player"):
		print("Collected a coin!")
		# You would typically emit a signal or call a function on the player/game manager
		# to add the coin's value to the score.
		# Example:
		# get_tree().call_group("game_manager", "add_score", value)

		# Then, queue_free() the collectible
		queue_free()
