extends Node
# MAP RELATED
var chunk_size = 16
# GENERIC
var godot_version = "0.0-unstable"
var NewGame: bool = true
var ready_already = true
var cloud_position = Vector2(100,100)
# NPC / ANIMALS
var SpawnRadius = 50
# Player
var character_position: Vector2 = Vector2.ZERO
var ResetPlayerPosition: bool = true
var RoadWorks = false
var ForestCutting = false
var DigSand = false
var CollectWater = false
var CollectClay = false
var Hunting = false
var Terrain = "None"
var Animals = "None"
var Walking = false
var level = 1
var experience = 0
var experience_total = 0
var experience_required = get_required_experience(level + 1)
var FoodDeterioration = 1
var WaterDeterioration = 1
# Warmth
var Warmth: float = 100.0
var MaxWarmth: float = 100.0
# Health
var Health:int = 10
var MaxHealth:int = 10
# ACTION DATA
var CollectingSandAmount = 100
var CollectingWoodAmount = 100
var CollectingClayAmount = 100
var CollectingWaterAmount = 100
var CollectingFoodAmount = 100
# MULTIPLIERS
var ForestCuttingMultiplier = 1
var CollectClayMultiplier = 1
var CollectWaterMultiplier = 1
var RoadWorksMultiplier = 1
var HuntingMultiplier = 1
# Quests
var QuestWater = 0
var QuestFood = 0
var QuestTrees = 0
var QuestClay = 0
var QuestHunting = 0
# Dictionary to store item data
var animals_db = {}
var npc_db = {}
func switch_scene(scene_path: String):
	## Save the character's position
	character_position = $CharacterBody2D.position
	## Change the scene
	get_tree().change_scene(scene_path)
func save_player_positon(character_node: CharacterBody2D):
	character_position = character_node.position
func gain_quest_water(amount):
	QuestWater += amount
	if QuestWater > 10000:
		QuestWater = 10000
		CollectWaterMultiplier = 2
	return QuestWater
func gain_quest_food(amount):
	QuestFood += amount
	if QuestFood > 10000:
		QuestFood = 10000
		HuntingMultiplier = 2
	return QuestFood
func gain_quest_trees(amount):
	QuestTrees += amount
	if QuestTrees > 10000:
		QuestTrees = 10000
	return QuestTrees
func gain_quest_clay(amount) -> int:
	QuestClay += amount
	if QuestClay > 10000:
		QuestClay = 10000
		
	# Check if the quest is completed
	if QuestClay >= 5000:  # Example threshold for completing the quest
		complete_quest("Clay")
	return QuestClay
	
func complete_quest(quest_type: String):
	match quest_type:
		"Water":
			print("Quest for Water Completed!")
			# Perform actions related to completing the water quest
		"Food":
			print("Quest for Food Completed!")
			# Perform actions related to completing the food quest
		"Trees":
			print("Quest for Trees Completed!")
			# Perform actions related to completing the trees quest
		"Clay":
			print("Quest for Clay Completed!")
			# Perform actions related to completing the clay quest
		"Hunting":
			print("Quest for Hunting Completed!")
			# Perform actions related to completing the hunting quest
	# Reset the quest amount after completion
	QuestClay = 0
	
	# Update UI or perform other actions as needed
	
func get_required_experience(p_level):
	return round(pow(p_level, 1.8) + p_level * 4)
func gain_experience(amount):
	experience_total += amount
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()
func level_up():
	level += 1
	experience_required = get_required_experience(level +1)
