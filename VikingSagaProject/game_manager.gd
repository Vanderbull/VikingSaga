extends Node

class_name GameManager

# Preload the scene for better performance
@onready var my_scene = preload("res://assets/cave-npc/cave_npc.tscn")
@onready var fox_npc_scene = preload("res://assets/fox-npc/fox_npc.tscn")
@onready var animate_fire_scene = preload("res://assets/animated-fire/animated_fire.tscn")

@onready var globals = get_node("/root/Globals")
const TEST_CURVE = preload("res://data/curves/test_curve.tres")

signal toggle_game_paused(is_paused : bool)
signal toggle_quest_paused(is_paused : bool)

var playerData = PlayerData.new()

var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused",game_paused)

var quest_paused : bool = false:
	get:
		return quest_paused
	set(value):
		quest_paused = value
		get_tree().paused = quest_paused
		emit_signal("toggle_quest_paused",quest_paused)

# Reference to the DynamicArray script
var dynamic_array_instance = null

func spawn_animate_fire():
	var animate_fire_instance = animate_fire_scene.instantiate()
	if animate_fire_instance is Node2D:
		#var animate_fire_random_x = randi_range(0, 0)  # Adjust range based on your game's resolution
		#var animate_fire_random_y = randi_range(0, 0)
		animate_fire_instance.position = Vector2(globals.character_position.x, globals.character_position.y)
		add_child(animate_fire_instance)
		
func spawn_scene():
	# Create an instance of the loaded scene
	var fox_instance = fox_npc_scene.instantiate()
	# Optionally, set its position or other properties if it's a 2D/3D node
	if fox_instance is Node2D:
		# Generate random position within a range
		var fox_random_x = randi_range(-2500, 2500)  # Adjust range based on your game's resolution
		var fox_random_y = randi_range(-2500, 2500)
		fox_instance.position = Vector2(fox_random_x, fox_random_y)
	# Add the instance to the scene tree
	add_child(fox_instance)
	# Create an instance of the loaded scene
	var instance = my_scene.instantiate()
	# Optionally, set its position or other properties if it's a 2D/3D node
	if instance is Node2D:
		# Generate random position within a range
		var random_x = randi_range(-2500, 2500)  # Adjust range based on your game's resolution
		var random_y = randi_range(-2500, 2500)
		instance.position = Vector2(random_x, random_y)
	# Add the instance to the scene tree
	add_child(instance)

func _ready():
	%HelpMenu.hide()
	#$HelpMenu.hide()
	for i in range(globals.SpawnRadius):
		spawn_scene()
	print("Getting GameManager ready...")
	$MenuCanvasLayer.show()
	$world.hide()
	$InGameCanvasLayer.hide()
	$TileInfoWindow.hide()
	$Interface.hide()
	$Quests.hide()
	$QuestFinished.hide()
	randomize()
	# Load the DynamicArray script
	var DynamicArrayScript = preload("res://dynamic_array.gd")
	# Create an instance of the DynamicArray script
	dynamic_array_instance = DynamicArrayScript.new()
	# Manually call _ready() to initialize the instance
	dynamic_array_instance._ready()
	# Initialize Labels
	%Label.update_text(globals.level, globals.experience, globals.experience_required)
	%WarmthLabel.update_text(globals.Warmth,100)
	%FoodLabel.update_text(globals.QuestFood,100)
	%WaterLabel.update_text(globals.QuestWater,100)
	%HPLabel.update_text(0,0)
	
	#$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	#$Interface/WarmthBar/WarmthLabel.update_text(globals.Warmth,100)
	#$Interface/FoodBar/FoodLabel.update_text(globals.QuestFood,100)
	#$Interface/FoodBar/WaterLabel.update_text(globals.QuestWater,100)
	#$TileInfoWindow/PanelContainer/VBoxContainer/HPLabel.update_text(0,0)
	if( globals.NewGame ):
		initialize_gamemanager()
		globals.NewGame = false
	else:
		game_paused = false

func initialize_gamemanager():
	# ADDING ANIMALS TO ANIMALMAP
	#spawnAnimals()
	# ADDING NPC TO NPC MAP
	#spawnNPC()
	#var PLAYERDATA_PATH : String = "res://resources/PlayerData.gd"
	playerData = PlayerData.new()
	if OS.is_debug_build():
		game_paused = !game_paused
	pass
	
func spawnNPC():
	for i in range(globals.SpawnRadius):
		#var tilemap = $world/Npc
		var cell_position = Vector2i(randi_range(-globals.SpawnRadius, globals.SpawnRadius), randi_range(-globals.SpawnRadius, globals.SpawnRadius))
		# What NPC images should be used?
		var atlas_coords = Vector2i(randi_range(0, 10), randi_range(0, 10))
		# If grass then spawn NPC
		if( $world/TileMap.get_terrain_type(cell_position.x, cell_position.y) == "Grass"):
			$world/Npc.set_cell(0, cell_position, randi_range(0, 0) ,atlas_coords)
		#globals.npc_db["npc"] = {
		#	"x": cell_position.x,
		#	"y": cell_position.y
		#}		
		#for npc_name in globals.npc_db.keys():
		#	pass
			#var coords = globals.npc_db[npc_name]
				
func spawnAnimals():
	# ADDING ANIMALS TO ANIMALMAP
	for i in range(globals.SpawnRadius):
		#var tilemap = $world/AnimalMap

		var cell_position = Vector2i(randi_range(-globals.SpawnRadius, globals.SpawnRadius), randi_range(-globals.SpawnRadius, globals.SpawnRadius))
		var atlas_coords = Vector2i(0, 1)
		if( $world/TileMap.get_terrain_type(cell_position.x, cell_position.y) == "Grass"):
			$world/AnimalMap.set_cell(0, cell_position, randi_range(1, 8) ,atlas_coords)
		#globals.animals_db["rabbit"] = {
		#	"x": cell_position.x,
		#	"y": cell_position.y
		#}		
		#for animal_name in globals.animals_db.keys():
		#	pass
			#var coords = globals.animals_db[animal_name]

func _process(_delta):
	%godot_version.update_text()
	#$TileInfoWindow/PanelContainer/VBoxContainer/godot_version.update_text()
	%WarmthLabel.update_text(globals.Warmth,100)
	%FoodLabel.update_text(playerData.Food,1000)
	%WaterLabel.update_text(playerData.Water,1000)
	
	#$Interface/WarmthBar/WarmthLabel.update_text(globals.Warmth,100)
	#$Interface/FoodBar/FoodLabel.update_text(playerData.Food,1000)
	#$Interface/FoodBar/WaterLabel.update_text(playerData.Water,1000)
	if( globals.Walking == true):
		playerData.Food -= globals.FoodDeterioration
		playerData.Water -= globals.WaterDeterioration
	if(globals.Hunting):
		$InGameCanvasLayer/ProgressBar/Label.text = "Hunting Rabbit"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + globals.HuntingMultiplier )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.Hunting = not globals.Hunting
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
			playerData.Food += globals.CollectingFoodAmount
			globals.gain_experience(1)
			globals.gain_quest_food(globals.CollectingFoodAmount)
			$Quests/Control/Panel/VBoxContainer/Quest2.update_text()
	elif(globals.DigSand and globals.Terrain == "Sand"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Digging sand"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.Sand += globals.CollectingSandAmount
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.gain_experience(1)
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.ForestCutting and globals.Terrain == "Forest"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Cutting trees"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + globals.ForestCuttingMultiplier )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.Wood += globals.CollectingWoodAmount
			$InGameCanvasLayer/ProgressBar.value = 0
			#$world/TileMap2.set_cell(0, Vector2i(globals.player_position.x, globals.player_position.y), 1 ,Vector2(1,2))
			globals.gain_experience(1)
			globals.gain_quest_trees(globals.CollectingWoodAmount)
			$Quests/Control/Panel/VBoxContainer/Quest3.update_text()
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.CollectWater and globals.Terrain == "Water"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Collecting water"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + globals.CollectWaterMultiplier )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.Water += globals.CollectingWaterAmount
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.gain_experience(1)
			globals.gain_quest_water(globals.CollectingWaterAmount)
			$Quests/Control/Panel/VBoxContainer/Quest1.update_text()
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.CollectClay and globals.Terrain == "Grass"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Collecting Clay"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + globals.CollectClayMultiplier )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.Clay += globals.CollectingClayAmount
			globals.gain_experience(1)
			globals.gain_quest_clay(globals.CollectingClayAmount)
			$Quests/Control/Panel/VBoxContainer/Quest4.update_text()
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
			$InGameCanvasLayer/ProgressBar.value = 0
	else:
		$InGameCanvasLayer/ProgressBar.hide()
		$InGameCanvasLayer/ProgressBar.value = 0
		
	$InGameCanvasLayer/Panel/HBoxContainer/Trees.text = "Trees: " + str(playerData.Wood)
	$InGameCanvasLayer/Panel/HBoxContainer/Sand.text = "Sand: " + str(playerData.Sand)
	$InGameCanvasLayer/Panel/HBoxContainer/Water.text = "Water: " + str(playerData.Water)
	$InGameCanvasLayer/Panel/HBoxContainer/Clay.text = "Clay: " + str(playerData.Clay)
	$InGameCanvasLayer/Panel/HBoxContainer/Food.text = "Food: " + str(playerData.Food)
	
func _input(event : InputEvent):
	if(event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused

func _on_inventory_gui_closed():
	get_tree().paused = false

func _on_inventory_gui_opened():
	get_tree().paused = true
	
func _on_in_game_canvas_layer_tree_entered() -> void:
	print("Entered the InGameCanvasLayer Tree..")

func _on_in_game_canvas_layer_visibility_changed() -> void:
	if $InGameCanvasLayer.visible:
		print("InGameCanvasLayer is visible")
		if $InGameCanvasLayer/Panel.visible:
			print("InGameCanvasLayer/Panel is visible")
	else:
		print("InGameCanvasLayer is hidden")
		for child in get_children():
			if child is CanvasItem:
				print("InGameCanvasLayer is hidden")
				child.visible = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("in the zone")
	playerData.Food = 1000
	playerData.Water = 1000


func _on_quest_1_ready() -> void:
	pass # Replace with function body.
