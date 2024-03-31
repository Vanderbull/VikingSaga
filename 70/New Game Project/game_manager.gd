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
	if OS.is_debug_build():
		print("Debug mode enabled")
		print(TEST_CURVE.sample(0.25))
		
func _process(delta):
	$InGameCanvasLayer/Trees.text = "Trees: " + str(playerData.PlayerWood)
	
		
func _input(event : InputEvent):
	if(event.is_action_pressed("ui_cancel")):
		game_paused = !game_paused
	if(event.is_action_pressed("ui_home")):
		quest_paused = !quest_paused
