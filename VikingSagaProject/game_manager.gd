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
		
func _ready():
	$world.hide()
	$InGameCanvasLayer.hide()
	var PLAYERDATA_PATH : String = "res://resources/PlayerData.gd"
	
	playerData = PlayerData.new()
	#playerData = load("res://resources/PlayerData.gd")
	#ResourceLoader.load_threaded_request(PLAYERDATA_PATH)
	#playerData = ResourceLoader.load_threaded_get(PLAYERDATA_PATH)
	if OS.is_debug_build():
		print("Debug mode enabled")
		print(TEST_CURVE.sample(0.25))
		game_paused = !game_paused
		
func _process(delta):
	#if(globals.RoadWorks and playerData.PlayerWood > 0):
		#$InGameCanvasLayer/ProgressBar/Label.text = "Building road"
		#$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		#if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			#playerData.PlayerWood -= 1
			#$InGameCanvasLayer/ProgressBar.value = 0
			#globals.RoadWorks = false
	if( globals.Walking == true):
		playerData.PlayerFood -= 1
		playerData.PlayerWater -= 1
	if( globals.Hunt == true):
		playerData.PlayerFood += 1
		
		
	if(globals.DigSand and globals.Terrain == "Sand"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Digging sand"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerSand += 1
			$InGameCanvasLayer/ProgressBar.value = 0
	elif(globals.ForestCutting and globals.Terrain == "Forest"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Cutting trees"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerWood += 1
			$InGameCanvasLayer/ProgressBar.value = 0
	elif(globals.CollectWater and globals.Terrain == "Water"):
		$InGameCanvasLayer/ProgressBar/Label.text = "Collecting water"
		$InGameCanvasLayer/ProgressBar.set_value( $InGameCanvasLayer/ProgressBar.value + 1 )
		if( $InGameCanvasLayer/ProgressBar.value == 100 ):
			playerData.PlayerWater += 1
			$InGameCanvasLayer/ProgressBar.value = 0
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
	#if(event.is_action_pressed("ui_home")):
	#	quest_paused = !quest_paused


func _on_inventory_gui_closed():
	get_tree().paused = false


func _on_inventory_gui_opened():
	get_tree().paused = true
