extends Node

#@onready var game_manager = $"../../.."
#@onready var player = $world/TileMap/Player
var character_position: Vector2 = Vector2.ZERO

var ResetPlayerPosition: bool = true
var NewGame: bool = true
var Warmth: float = 100.0
var MaxWarmth: float = 100.0

var Health:int = 10
var MaxHealth:int = 10

# ACTION DATA
var ForestCuttingAmount = 1000
var CollectingClayAmount = 1000
var CollectingWaterAmount = 1000
var HuntingAmount = 1000
# MULTIPLIERS
var ForestCuttingMultiplier = 1
var CollectClayMultiplier = 1
var CollectWaterMultiplier = 1
var RoadWorksMultiplier = 1
var HuntingMultiplier = 1

var ready_already = true
#var player_position = Vector2(0,0)
var cloud_position = Vector2(100,100)

var RoadWorks = false
var ForestCutting = false
var DigSand = false
var CollectWater = false
var CollectClay = false
var Hunting = false

var QuestWater = 10000
var QuestFood = 10000
var QuestTrees = 10000
var QuestClay = 10000
var QuestHunting = 10000

var Terrain = "None"
var Animals = "None"

var Walking = false

var level = 1

var experience = 0
var experience_total = 0
var experience_required = get_required_experience(level + 1)

# Dictionary to store item data
var animals_db = {}
var npc_db = {}

#func switch_scene(scene_path: String):
	## Save the character's position
	#character_position = $CharacterBody2D.position
	## Change the scene
	#get_tree().change_scene(scene_path)
	
func save_player_positon(character_node: CharacterBody2D):
	#print("$Player position: %s",$world/TileMap/Player.position)
	character_position = character_node.position
	print("character_position %s",character_position)

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
func gain_quest_clay(amount):
	QuestClay += amount
	if QuestClay > 10000:
		QuestClay = 10000
	return QuestClay
	
func update_quests():
	$Quests/VBoxContainer/Quest1.text = "UPDATE QUEST 1"
	$Quests/VBoxContainer/Quest2.text = "UPDATE QUEST 2"
	$Quests/VBoxContainer/Quest3.text = "UPDATE QUEST 3"
	
func get_required_experience(level):
	return round(pow(level, 1.8) + level * 4)

func gain_experience(amount):
	experience_total += amount
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()
		
func level_up():
	level += 1
	experience_required = get_required_experience(level +1)
	
