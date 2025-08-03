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
#var experience_required = get_required_experience(level + 1)
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
# Carried items and there amount
var CarriedWater = 0
var CarriedFood = 0
var CarriedTrees = 0
var CarriedClay = 0
# Stored items and there amount
var StoredWater = 0
var StoredFood = 0
var StoredTrees = 0
var StoredClay = 0
# Quests ( Should be replaced with carried and stored variables )
#var QuestWater = 0
#var QuestFood = 0
#var QuestTrees = 0
#var QuestClay = 0
var QuestRoads = 0
var QuestHunting = 0
# Dictionary to store item data
var animals_db = {}
var npc_db = {}
# Declare the variable to store the GPU name
var gpu_name: String
# Declare the variable to store the GPU vendor
var gpu_vendor: String
# Declare the variable to store the RENDERING driver
var rendering_driver: String
var intro_video_played: bool = false

# ENUMS
enum TerrainType {
	GRASS,
	WATER,
	SAND,
	MOUNTAIN,
	FOREST,
	SNOW
}
# Functions
func _ready() -> void:
	print("Initializing globals...")
	print("--- GPU Information ---")
	# Get GPU adapter name (e.g., "NVIDIA GeForce RTX 3080", "AMD Radeon RX 6800XT", "Intel(R) Iris(TM) Xe Graphics")
	gpu_name = RenderingServer.get_video_adapter_name()
	print("GPU Name: " + gpu_name)
	# Get GPU vendor name (e.g., "NVIDIA Corporation", "Advanced Micro Devices, Inc.", "Intel")
	gpu_vendor = RenderingServer.get_video_adapter_vendor()
	print("GPU Vendor: " + gpu_vendor)
	rendering_driver = RenderingServer.get_current_rendering_driver_name()
	print("Rendering Driver: " + rendering_driver)
		
func switch_scene(scene_path: String):
	## Save the character's position
	character_position = $CharacterBody2D.position
	## Change the scene
	get_tree().change_scene(scene_path)
func save_player_positon(character_node: CharacterBody2D):
	character_position = character_node.position
func gain_quest_water(amount):
	quest_water += amount
	if quest_water > MAX_QUEST_WATER:
		quest_water = MAX_QUEST_WATER
		CollectWaterMultiplier = 2
	return quest_water
func gain_quest_food(amount):
	quest_food += amount
	if quest_food > MAX_QUEST_FOOD:
		quest_food = MAX_QUEST_FOOD
		HuntingMultiplier = 2
	return quest_food
func gain_quest_trees(amount):
	quest_wood += amount
	if quest_wood > MAX_QUEST_WOOD:
		quest_wood = MAX_QUEST_WOOD
	return quest_wood
func gain_quest_clay(amount) -> int:
	quest_clay += amount
	if quest_clay > MAX_QUEST_CLAY:
		quest_clay = MAX_QUEST_CLAY
	return quest_clay
	
# --- Declare quest water and multiplier variables ---
# Initialize them with their starting values.
var quest_water: float = 0.0
var collect_water_multiplier: float = 1.0
# --- Define the maximum amount for quest water ---
const MAX_QUEST_WATER: float = 10000.0
# --- Define the multiplier value when max water is reached ---
const WATER_MAX_MULTIPLIER_VALUE: float = 2.0
# --- Declare quest food and multiplier variables ---
# Initialize them with their starting values.
var quest_food: float = 0.0
var collect_food_multiplier: float = 1.0
# --- Define the maximum amount for quest food ---
const MAX_QUEST_FOOD: float = 10000.0
# --- Define the multiplier value when max food is reached ---
const FOOD_MAX_MULTIPLIER_VALUE: float = 2.0
# --- Declare quest wood and multiplier variables ---
# Initialize them with their starting values.
var quest_wood: float = 0.0
var collect_wood_multiplier: float = 1.0
# --- Define the maximum amount for quest wood ---
const MAX_QUEST_WOOD: float = 10000.0
# --- Define the multiplier value when max wood is reached ---
const WOOD_MAX_MULTIPLIER_VALUE: float = 2.0
# --- Declare quest clay and multiplier variables ---
# Initialize them with their starting values.
var quest_clay: float = 0.0
var collect_clay_multiplier: float = 1.0
# --- Define the maximum amount for quest clay ---
const MAX_QUEST_CLAY: float = 10000.0
# --- Define the multiplier value when max clay is reached ---
const CLAY_MAX_MULTIPLIER_VALUE: float = 2.0
# --- Declare quest sand and multiplier variables ---
# Initialize them with their starting values.
var quest_sand: float = 0.0
var collect_sand_multiplier: float = 1.0
# --- Define the maximum amount for quest sand ---
const MAX_QUEST_SAND: float = 10000.0
# --- Define the multiplier value when max sand is reached ---
const SAND_MAX_MULTIPLIER_VALUE: float = 2.0

func gain_resource(current_resource_amount: float, amount_to_add: float, max_resource_amount: float, multiplier_variable_to_set: StringName = &"", multiplier_value: float = 1.0) -> float:
	var new_resource_amount = current_resource_amount + amount_to_add

	if new_resource_amount > max_resource_amount:
		new_resource_amount = max_resource_amount
		# If a multiplier variable name is provided, set its value
		if multiplier_variable_to_set != &"":
			# This assumes the multiplier variable is a property of the current script
			# Or a globally accessible variable (e.g., in a singleton)
			set(multiplier_variable_to_set, multiplier_value)
			# If it's a global singleton, you'd access it like:
			# GlobalSingleton.set(multiplier_variable_to_set, multiplier_value)

	return new_resource_amount
