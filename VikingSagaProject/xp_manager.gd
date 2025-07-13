# xp_manager.gd
# This script defines functions for calculating RPG experience progression.

extends Node

# Default base experience for level 1.
# This value determines the initial difficulty.
const DEFAULT_BASE_XP: int = 100
# Default rate at which experience requirement increases per level.
# A higher value means a steeper increase in XP needed for higher levels.
# Common values are between 1.2 and 2.0.
const DEFAULT_GROWTH_RATE: float = 1.5

func _ready() -> void:
	# Example usage when the script is run in Godot.
	# This acts similarly to Python's `if __name__ == "__main__":` block.
	print("--- Experience to Reach Specific Levels (Cumulative XP) ---")
	for level in range(1, 11):
		var xp_needed: int = calculate_xp_for_level(level)
		print("To reach Level %d: %d XP total" % [level, xp_needed])

	print("\n--- Experience Needed for Next Level (Per Level) ---")
	for level in range(1, 11):
		var xp_to_advance: int = get_xp_for_next_level(level)
		print("From Level %d to %d: %d XP" % [level, level + 1, xp_to_advance])

	print("\n--- Custom Parameters Example ---")
	var custom_base_xp: int = 150
	var custom_growth_rate: float = 1.3
	var level_for_custom_example: int = 15
	var xp_to_reach_custom: int = calculate_xp_for_level(level_for_custom_example, custom_base_xp, custom_growth_rate)
	print("To reach Level %d (base_xp=%d, growth_rate=%.1f): %d XP total" % [level_for_custom_example, custom_base_xp, custom_growth_rate, xp_to_reach_custom])

	var current_level_for_custom_next: int = 14
	var xp_to_next_custom: int = get_xp_for_next_level(current_level_for_custom_next, custom_base_xp, custom_growth_rate)
	print("From Level %d to %d (base_xp=%d, growth_rate=%.1f): %d XP" % [current_level_for_custom_next, current_level_for_custom_next + 1, custom_base_xp, custom_growth_rate, xp_to_next_custom])


func calculate_xp_for_level(level: int, base_xp: int = DEFAULT_BASE_XP, growth_rate: float = DEFAULT_GROWTH_RATE) -> int:
	"""
	Calculates the total experience required to reach a given level in an RPG.

	This function uses a common formula where the experience required for each
	subsequent level increases at an accelerating rate, providing a satisfying
	progression curve where early levels are quick and later levels require
	more dedication.

	Args:
		level (int): The target level. Must be a positive integer.
		base_xp (int): The base experience required for level 1.
					   This value determines the initial difficulty.
		growth_rate (float): The rate at which the experience requirement
							 increases per level. A higher value means a steeper
							 increase in XP needed for higher levels.
							 Common values are between 1.2 and 2.0.

	Returns:
		int: The total experience points required to reach the start of the
			 specified level. Returns 0 for level 1 (as no XP is needed to
			 reach the start of level 1, only to complete it).

	Raises:
		Error: If the level is less than 1, an error will be printed to the console.
	"""
	if level < 1:
		# In GDScript, you typically print an error or assert.
		# For a more robust game, you might use `assert(level >= 1)` or return -1.
		# Here, we'll print an error and return 0 as a fallback.
		push_error("Level must be a positive integer.")
		return 0
	if level == 1:
		return 0 # No XP needed to reach the start of level 1

	var total_xp_needed: int = 0
	# GDScript's range(start, end) is exclusive of 'end', so range(1, level) is correct.
	for i in range(1, level):
		# Experience needed to go from level i to level i+1
		# GDScript uses `pow()` for exponentiation.
		var xp_to_next_level: int = int(base_xp * pow(i, growth_rate))
		total_xp_needed += xp_to_next_level
	return total_xp_needed

func get_xp_for_next_level(current_level: int, base_xp: int = DEFAULT_BASE_XP, growth_rate: float = DEFAULT_GROWTH_RATE) -> int:
	"""
	Calculates the experience required to advance from the current level to the next.

	Args:
		current_level (int): The player's current level.
		base_xp (int): The base experience required for level 1.
		growth_rate (float): The rate at which the experience requirement increases.

	Returns:
		int: The experience points needed to go from `current_level` to `current_level + 1`.

	Raises:
		Error: If the current_level is less than 1, an error will be printed to the console.
	"""
	if current_level < 1:
		push_error("Current level must be a positive integer.")
		return 0

	# XP needed to complete the current level and reach the next one
	# GDScript uses `pow()` for exponentiation.
	var xp_to_next_level: int = int(base_xp * pow(current_level, growth_rate))
	return xp_to_next_level
func increase_experience(current_xp: int, xp_gained: int, current_level: int, base_xp: int = DEFAULT_BASE_XP, growth_rate: float = DEFAULT_GROWTH_RATE) -> Dictionary:
	"""
	Increases the player's experience and handles level-ups.

	Args:
		current_xp (int): The player's current experience points.
		xp_gained (int): The amount of experience points gained.
		current_level (int): The player's current level.
		base_xp (int): The base experience required for level 1.
		growth_rate (float): The rate at which the experience requirement increases.

	Returns:
		Dictionary: A dictionary containing the updated "current_xp" and "current_level".
	"""
	var new_xp: int = current_xp + xp_gained
	var new_level: int = current_level

	var xp_needed_for_next_level: int = get_xp_for_next_level(new_level, base_xp, growth_rate)

	# Loop to handle multiple level-ups at once
	while new_xp >= xp_needed_for_next_level:
		new_xp -= xp_needed_for_next_level
		new_level += 1
		emit_signal("level_up", new_level) # Emit signal for level up
		print("LEVEL UP! Reached Level %d!" % new_level)
		xp_needed_for_next_level = get_xp_for_next_level(new_level, base_xp, growth_rate)

	return {"current_xp": new_xp, "current_level": new_level}
