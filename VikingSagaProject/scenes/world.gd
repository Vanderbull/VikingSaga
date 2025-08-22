extends Node2D

@export var help_menu: CanvasLayer

@onready var globals = get_node("/root/Globals")
@onready var player = $TileMap/Player
@onready var camera = $"TileMap/Player/follow cam"

const ENEMY_SCENE_PATH : String = "res://scenes/city/city.tscn"

var enemy = null
var PlayerGridPosition = Vector2i(0,0)
var PlayerCuttingTrees = false
var CurrentArea
var file_name = "world.gd"

func game_over():
	# Load the Game Over screen scene
	var game_over_scene = preload("res://scenes/gameover/game_over.tscn").instantiate()
	get_tree().root.add_child(game_over_scene)

# Called when the node enters the scene tree for the first time.
func _ready():
	#$"../HelpMenu".hide()
	#player.position = Vector2i(0,0)
	#player.global_position = Vector2i(0,0)
	pass
	ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
	#var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)

func _process(_delta):
	Globals.save_player_positon(player)

func _unhandled_input(event):
	if event.is_action_pressed("spawn_animate_fire"):
		$"..".spawn_animate_fire()
	if event.is_action_pressed("reload_current_scene"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("enter_city_scene"):
		get_tree().change_scene_to_file("res://scenes/city/city.tscn")
	if event.is_action_pressed("enter_battle_scene"):
		get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")			
	if event.is_action_pressed("toggle_help_menu"):
		if help_menu:
			help_menu.visible = not help_menu.visible

func _on_area_2d_body_entered(_body):
	$HUD/StatusInfo/Label.visible = true
	$HUD/StatusInfo/EnterButton.visible = true

func _on_area_2d_body_exited(_body):
	$HUD/StatusInfo/Label.visible = false
	$HUD/StatusInfo/EnterButton.visible = false

func _on_forest_body_entered(_body):
	PlayerCuttingTrees = true

func _on_forest_body_exited(_body):
	PlayerCuttingTrees = false
