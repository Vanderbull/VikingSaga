extends Node

class_name GameManager

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

func _ready():
	randomize()
	# Load the DynamicArray script
	var DynamicArrayScript = preload("res://dynamic_array.gd")
	# Create an instance of the DynamicArray script
	dynamic_array_instance = DynamicArrayScript.new()
	
	# Add the dynamic array node to the scene tree if needed
	# add_child(dynamic_array_instance)
	
	# Manually call _ready() to initialize the instance
	dynamic_array_instance._ready()
	
	#var tile_pos = worldMap.local_to_map($world/TileMap/Player.position)
	#globals.player_position = tile_pos
	print_debug(globals.player_position)
	#print(dynamic_array_instance.find_coordinate_with_text(tile_pos.x,tile_pos.y))
	var TileCoordinateText = dynamic_array_instance.find_coordinate_with_text(globals.player_position.x,globals.player_position.y)
	$TileInfoWindow/PanelContainer/VBoxContainer/TileCoordinates.text = TileCoordinateText
	
	$world/TileMap.get_terrain_type(2, 0)
	
	for i in range(5):
		var tilemap = $world/AnimalMap
		var cell_position = Vector2i(randi_range(-10, 10), randi_range(-10, 10))
		var atlas_coords = Vector2i(0, 0)
		var tile_id = 1
	
		if( $world/TileMap.get_terrain_type(cell_position.x, cell_position.y) == "Grass"):
			$world/AnimalMap.set_cell(0, cell_position, 2 ,atlas_coords)
			
		globals.animals_db["rabbit"] = {
			"x": cell_position.x,
			"y": cell_position.y
		}
		
		for animal_name in globals.animals_db.keys():
			var coords = globals.animals_db[animal_name]
			print("Coordinates of ", animal_name, ": x = ", coords["x"], ", y = ", coords["y"])

	
	$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	#$Interface/Label.text = """Level: %s
								#Experience: %s
								#Next level: %s
								#""" % [globals.level,globals.experience,globals.experience_required]
	$world.hide()
	$InGameCanvasLayer.hide()
	var PLAYERDATA_PATH : String = "res://resources/PlayerData.gd"
	
	playerData = PlayerData.new()
	#playerData = load("res://resources/PlayerData.gd")
	#ResourceLoader.load_threaded_request(PLAYERDATA_PATH)
	#playerData = ResourceLoader.load_threaded_get(PLAYERDATA_PATH)
	if OS.is_debug_build():
		#print_debug("Debug mode enabled")
		#print_debug(TEST_CURVE.sample(0.25))
		game_paused = !game_paused
		
func _process(delta):
	if( globals.Walking == true):
		playerData.PlayerFood -= 1
		playerData.PlayerWater -= 1
	if(globals.Hunting and globals.Animals == "Rabbit"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Hunting Rabbit"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerFood += 1
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.gain_experience(1)
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.DigSand and globals.Terrain == "Sand"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Digging sand"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerSand += 1
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.gain_experience(1)
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.ForestCutting and globals.Terrain == "Forest"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Cutting trees"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerWood += 1
			$InGameCanvasLayer/ProgressBar.value = 0
			$world/TileMap2.set_cell(0, Vector2i(globals.player_position.x, globals.player_position.y), 1 ,Vector2(1,2))
			globals.gain_experience(1)
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.CollectWater and globals.Terrain == "Water"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Collecting water"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerWater += 1
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.gain_experience(1)
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	elif(globals.CollectClay and globals.Terrain == "Grass"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Collecting Clay"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerClay += 1
			$InGameCanvasLayer/ProgressBar.value = 0
			globals.gain_experience(1)
			$Interface/Label.update_text(globals.level, globals.experience, globals.experience_required)
	else:
		$InGameCanvasLayer/ProgressBar.hide()
		$InGameCanvasLayer/ProgressBar.value = 0
		
	$InGameCanvasLayer/Panel/HBoxContainer/Trees.text = "Trees: " + str(playerData.PlayerWood)
	$InGameCanvasLayer/Panel/HBoxContainer/Sand.text = "Sand: " + str(playerData.PlayerSand)
	$InGameCanvasLayer/Panel/HBoxContainer/Water.text = "Water: " + str(playerData.PlayerWater)
	$InGameCanvasLayer/Panel/HBoxContainer/Clay.text = "Clay: " + str(playerData.PlayerClay)
	$InGameCanvasLayer/Panel/HBoxContainer/Food.text = "Food: " + str(playerData.PlayerFood)
	
func _input(event : InputEvent):
	if(event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused

func _on_inventory_gui_closed():
	get_tree().paused = false

func _on_inventory_gui_opened():
	get_tree().paused = true
