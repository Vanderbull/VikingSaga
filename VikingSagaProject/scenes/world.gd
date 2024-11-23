extends Node2D

@onready var globals = get_node("/root/Globals")
@onready var player = $TileMap/Player
@onready var camera = $"TileMap/Player/follow cam"

const ENEMY_SCENE_PATH : String = "res://city.tscn"

var enemy = null
var PlayerGridPosition = Vector2i(0,0)
var PlayerCuttingTrees = false
var CurrentArea
var file_name = "world.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Getting world ready...")
	#player.position = Vector2i(0,0)
	#player.global_position = Vector2i(0,0)
	pass
	ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
	var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)

func _process(_delta):
	Globals.save_player_positon(player)
	var time = Time.get_time_dict_from_system()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_1:
			print_debug("Debug: This is coming from file: ", file_name)
		if event.pressed and event.keycode == KEY_2:
			print_debug("Debug: This is coming from file: ", file_name)
		if event.pressed and event.keycode == KEY_3:
			print_debug("Debug: Change scene to file: res://scenes/world.tscn")
			get_tree().change_scene_to_file("res://scenes/world.tscn")
		if event.pressed and event.keycode == KEY_4:
			print_debug("Debug: Change scene to file: res://city.tscn")
			get_tree().change_scene_to_file("res://city.tscn")
			# FIGHTING SCENE
		if event.pressed and event.keycode == KEY_5:
			print_debug("Debug: Change scene to file: res://quest/quest_canvas_layer.tscn")
			get_tree().change_scene_to_file("res://quest/quest_canvas_layer.tscn")
		if event.pressed and event.keycode == KEY_6:
			print_debug("Debug: This is coming from file: ", file_name)
		if event.pressed and event.keycode == KEY_7:
			print_debug("Debug: Reloading current scene")
			get_tree().reload_current_scene()
		if event.pressed and event.keycode == KEY_8:
			print_debug("Debug: This is coming from file: ", file_name)
		if event.pressed and event.keycode == KEY_9:
			print_debug("Debug: This is coming from file: ", file_name)
		if event.pressed and event.keycode == KEY_0:
			print_debug("Debug: This is coming from file: ", file_name)

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
