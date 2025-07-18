extends Node

class_name GameManager

# Reference to the PatchManager node
@onready var patch_manager = $PatchManager
# Preload the scene for better performance
@onready var my_scene = preload("res://assets/cave-npc/cave_npc.tscn")
@onready var fox_npc_scene = preload("res://assets/fox-npc/fox_npc.tscn")
@onready var city_1_scene = preload("res://assets/cities/city-1.tscn")
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
var noise = FastNoiseLite.new()

func spawn_animate_fire():
	var animate_fire_instance = animate_fire_scene.instantiate()
	if animate_fire_instance is Node2D:
		#var animate_fire_random_x = randi_range(0, 0)  # Adjust range based on your game's resolution
		#var animate_fire_random_y = randi_range(0, 0)
		animate_fire_instance.position = Vector2(globals.character_position.x, globals.character_position.y)
		add_child(animate_fire_instance)

var occupied_positions = []

func is_position_valid(new_pos: Vector2, min_distance: float) -> bool:
	for pos in occupied_positions:
		if pos.distance_to(new_pos) < min_distance:
			return false
	return true

func place_city(city_instance: Node2D, min_distance: float = 2000.0):
	if city_instance is Node2D:
		var attempts = 100  # Avoid infinite loops by limiting attempts
		while attempts > 0:
			var random_x = randi_range(-10000, 10000)
			var random_y = randi_range(-10000, 10000)
			var new_position = Vector2(random_x, random_y)
			
			if is_position_valid(new_position, min_distance):
				city_instance.position = new_position
				occupied_positions.append(new_position)
				add_child(city_instance)
				#print(new_position )
				return  # Exit after placing

			attempts -= 1
		
		print("Warning: Could not find a valid position for city instance.")
		
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
	# -------------------------------------------------------------------
		# Create an instance of the loaded scene
	var city_instance = city_1_scene.instantiate()
	place_city(city_instance,100)
	
	## Optionally, set its position or other properties if it's a 2D/3D node
	#if city_instance is Node2D:
		## Generate random position within a range
		#var random_x = randi_range(-2500, 2500)  # Adjust range based on your game's resolution
		#var random_y = randi_range(-2500, 2500)
		#city_instance.position = Vector2(random_x, random_y)
	## Add the instance to the scene tree
	#add_child(city_instance)

func generate_minimap(size: int, margin: int) -> ImageTexture:
	#var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.02
	noise.seed = randi()  # Set a random seed each time

	var image = Image.create(size, size, false, Image.FORMAT_RGB8)
	# Fill with a border color (optional)
	var border_color = Color(0, 0, 0)  # Black border (change as needed)

	for x in range(size):
		for y in range(size):
			if x < margin or y < margin or x >= size - margin or y >= size - margin:
				# Set the margin area to a solid color (e.g., black)
				image.set_pixel(x, y, border_color)
			else:
				# Apply noise inside the margin
				var val = noise.get_noise_2d(x, y)
				val = (val + 1) / 2.0  # Normalize the noise value
				var color = Color(val, val, val, 1.0)  # Greyscale based on noise
				if val < 0.3:
					color = Color(0, 0, 1)  # Water
				elif val < 0.6:
					color = Color(0, 1, 0)  # Grass
				else:
					color = Color(0.5, 0.25, 0)  # Mountain
				image.set_pixel(x, y, color)

	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

@onready var minimap_rect = $Interface/Control/Minimap

func _ready():
	print("--- GPU Information ---")
	# Get GPU adapter name (e.g., "NVIDIA GeForce RTX 3080", "AMD Radeon RX 6800XT", "Intel(R) Iris(TM) Xe Graphics")
	var gpu_name = RenderingServer.get_video_adapter_name()
	print("GPU Name: " + gpu_name)
	# Get GPU vendor name (e.g., "NVIDIA Corporation", "Advanced Micro Devices, Inc.", "Intel")
	var gpu_vendor = RenderingServer.get_video_adapter_vendor()
	print("GPU Vendor: " + gpu_vendor)
	var rendering_driver = RenderingServer.get_current_rendering_driver_name()
	print("Rendering Driver: " + rendering_driver)

	#patch_manager.apply_patch("res://patch_manager/patch_1.json")
	randomize()
	var minimap_texture = generate_minimap(128,10)  # Generate a 128x128 minimap
	minimap_rect.texture = minimap_texture  # Assign the texture
	# Hide things initially
	%HelpMenu.hide()
	$world.hide()
	$InGameCanvasLayer.hide()
	$TileInfoWindow.hide()
	$Interface.hide()
	%Quests.hide() #$Quests.hide()
	%QuestFinished.hide() #$QuestFinished.hide()
	for i in range(globals.SpawnRadius):
		spawn_scene()
	$MenuCanvasLayer.show()
	# Load the DynamicArray script
	var DynamicArrayScript = preload("res://dynamic_array.gd")
	# Create an instance of the DynamicArray script
	dynamic_array_instance = DynamicArrayScript.new()
	# Manually call _ready() to initialize the instance
	dynamic_array_instance._ready()
	# Initialize Labels
	#%Label.update_text(globals.level, globals.experience, globals.experience_required)
	%WarmthLabel.update_text(globals.Warmth,100)
	%FoodLabel.update_text(globals.QuestFood,100)
	%WaterLabel.update_text(globals.QuestWater,100)
	%HPLabel.update_text(0,0)
	if( globals.NewGame ):
		initialize_gamemanager()
		globals.NewGame = false
	else:
		game_paused = false

func initialize_gamemanager():
	playerData = PlayerData.new()
	if OS.is_debug_build():
		game_paused = !game_paused
	pass

#func spawnNPC():
	#for i in range(globals.SpawnRadius):
		##var tilemap = $world/Npc
		#var cell_position = Vector2i(randi_range(-globals.SpawnRadius, globals.SpawnRadius), randi_range(-globals.SpawnRadius, globals.SpawnRadius))
		## What NPC images should be used?
		#var atlas_coords = Vector2i(randi_range(0, 10), randi_range(0, 10))
		## If grass then spawn NPC
		#if( $world/TileMap.get_terrain_type(cell_position.x, cell_position.y) == "Grass"):
			#$world/Npc.set_cell(0, cell_position, randi_range(0, 0) ,atlas_coords)
#
#func spawnAnimals():
	## ADDING ANIMALS TO ANIMALMAP
	#for i in range(globals.SpawnRadius):
		#var cell_position = Vector2i(randi_range(-globals.SpawnRadius, globals.SpawnRadius), randi_range(-globals.SpawnRadius, globals.SpawnRadius))
		#var atlas_coords = Vector2i(0, 1)
		#if( $world/TileMap.get_terrain_type(cell_position.x, cell_position.y) == "Grass"):
			#$world/AnimalMap.set_cell(0, cell_position, randi_range(1, 8) ,atlas_coords)

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	$TileInfoWindow/PanelContainer/VBoxContainer/FPS.text = "FPS: %d" % fps
	#%godot_version.update_text()
	%WarmthLabel.update_text(globals.Warmth,100)
	%FoodLabel.update_text(playerData.Food,1000)
	%WaterLabel.update_text(playerData.Water,1000)
	
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
			%QuestFood.update_text()
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
			%QuestTrees.update_text()
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.CollectWater and globals.Terrain == "Water"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Collecting water"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + globals.CollectWaterMultiplier )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.Water += globals.CollectingWaterAmount
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.gain_experience(1)
			globals.gain_quest_water(globals.CollectingWaterAmount)
			%QuestWater.update_text()
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.CollectClay and globals.Terrain == "Grass"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Collecting Clay"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + globals.CollectClayMultiplier )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.Clay += globals.CollectingClayAmount
			globals.gain_experience(1)
			globals.gain_quest_clay(globals.CollectingClayAmount)
			%QuestClay.update_text()
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
			$InGameCanvasLayer/ProgressBar.value = 0
	else:
		$InGameCanvasLayer/ProgressBar.hide()
		$InGameCanvasLayer/ProgressBar.value = 0
		
	$InGameCanvasLayer/%Trees.text = "Trees: " + str(playerData.Wood)
	$InGameCanvasLayer/%Sand.text = "Sand: " + str(playerData.Sand)
	$InGameCanvasLayer/%Water.text = "Water: " + str(playerData.Water)
	$InGameCanvasLayer/%Clay.text = "Clay: " + str(playerData.Clay)
	$InGameCanvasLayer/%Food.text = "Food: " + str(playerData.Food)
	
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

#func _on_area_2d_area_entered(area: Area2D) -> void:
	#print("in the zone")
	#playerData.Food = 1000
	#playerData.Water = 1000

func _on_quest_1_ready() -> void:
	pass # Replace with function body.
