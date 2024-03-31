extends Node2D

@onready var globals = get_node("/root/Globals")

@onready var heartsContainer = $HUD/TopRightPanel/heartsContainer
@onready var heartsContainer2 = $HUD/TopLeftPanel/heartsContainer2
@onready var player = $TileMap/Player
@onready var camera = $"TileMap/Player/follow cam"
@onready var slime = $TileMap/slime
@onready var slime2 = $TileMap/slime2
@onready var ship = $TileMap/Path2D/PathFollow2D/Ship
@onready var timered = $Timer

const ENEMY_SCENE_PATH : String = "res://city.tscn"

var enemy = null
var PlayerGridPosition = Vector2i(0,0)
var PlayerCuttingTrees = false
var CurrentArea

# Called when the node enters the scene tree for the first time.
func _ready():
	player.position = Vector2i(0,0)
	player.global_position = Vector2i(0,0)
	
	pass
	ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
	var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)


func _process(_delta):
	var time = Time.get_time_dict_from_system()

func _unhandled_input(event):
	if event is InputEventKey:
		#if event.pressed and event.keycode == KEY_1:
			#if globals.PlayerGold >= 1:
				#globals.PlayerGold -= 1
				#player.CurrentHealth = 10
				#heartsContainer.updateHearts(10)
		#if event.pressed and event.keycode == KEY_2:
			#if globals.playerGold >= 1:
				#globals.PlayerGold -= 1
				#ship.hp = 10
				#heartsContainer2.updateHearts(ship.hp)
		if event.pressed and event.keycode == KEY_3:
			get_tree().change_scene_to_file("res://scenes/world.tscn")
			enemy.visible = true
		if event.pressed and event.keycode == KEY_4:
			get_tree().change_scene_to_file("res://city.tscn")
		if event.pressed and event.keycode == KEY_5:
			get_tree().change_scene_to_file("res://quest/quest_canvas_layer.tscn")
		if event.pressed and event.keycode == KEY_6:
			pass
			#$QuestCanvasLayer/Control/ItemList.add_donkey() #.add_item("FIND A DONKEY")
		if event.pressed and event.keycode == KEY_7:
			globals.PlayerFood = 1000
			globals.PlayerWater = 1000
			globals.PlayerWood = 100

func _on_area_2d_body_entered(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = true
	$HUD/StatusInfo/EnterButton.visible = true
	pass # Replace with function body.


func _on_area_2d_body_exited(_body):
	$HUD/StatusInfo/Label.visible = false
	$HUD/StatusInfo/EnterButton.visible = false
	pass # Replace with function body.


func _on_sigtuna_area_body_entered(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = true
	$HUD/StatusInfo/EnterButton.visible = true
	$HUD/StatusInfo/RaidButton.visible = true
	$HUD/StatusInfo/Label.text = $TileMap/SigtunaArea/Identity.text
	CurrentArea = $TileMap/SigtunaArea/Identity.text
	pass # Replace with function body.


func _on_sigtuna_area_body_exited(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = false
	$HUD/StatusInfo/EnterButton.visible = false
	$HUD/StatusInfo/RaidButton.visible = false
	CurrentArea = ""
	pass # Replace with function body.


func _on_home_area_body_entered(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = true
	$HUD/StatusInfo/EnterButton.visible = true
	$HUD/StatusInfo/Label.text = $TileMap/HomeArea/Identity.text
	CurrentArea = $TileMap/HomeArea/Identity.text
	pass # Replace with function body.


func _on_home_area_body_exited(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = false
	$HUD/StatusInfo/EnterButton.visible = false
	$HUD/StatusInfo/RaidButton.visible = false
	CurrentArea = ""
	pass # Replace with function body.


func _on_birka_body_entered(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = true
	$HUD/StatusInfo/EnterButton.visible = true
	$HUD/StatusInfo/RaidButton.visible = true
	$HUD/StatusInfo/Label.text = $TileMap/BirkaArea/Identity.text
	CurrentArea = $TileMap/BirkaArea/Identity.text
	pass # Replace with function body.


func _on_birka_body_exited(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = false
	$HUD/StatusInfo/EnterButton.visible = false
	$HUD/StatusInfo/RaidButton.visible = false
	CurrentArea = ""
	pass # Replace with function body.


func _on_helgo_body_entered(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = true
	$HUD/StatusInfo/EnterButton.visible = true
	$HUD/StatusInfo/RaidButton.visible = true
	$HUD/StatusInfo/Label.text = $TileMap/HelgoArea/Identity.text
	CurrentArea = $TileMap/HelgoArea/Identity.text
	pass # Replace with function body.


func _on_helgo_body_exited(_body):
	print("body entered area")
	$HUD/StatusInfo/Label.visible = false
	$HUD/StatusInfo/EnterButton.visible = false
	$HUD/StatusInfo/RaidButton.visible = false
	CurrentArea = ""
	pass # Replace with function body.


func _on_forest_body_entered(_body):
	PlayerCuttingTrees = true

func _on_forest_body_exited(_body):
	PlayerCuttingTrees = false

func _on_quest_area_body_entered(_body):
	#$QuestCanvasLayer/Control/ItemList.add_item("FIND A DONKEY")
	$TileMap/QuestArea.queue_free()

func _on_raid_button_pressed():
	if CurrentArea == "Sigtuna settlement":
		$TileMap/SigtunaArea.queue_free()
	if CurrentArea == "Birka settlement":
		$TileMap/BirkaArea.queue_free()
	if CurrentArea == "Helgo settlement":
		$TileMap/HelgoArea.queue_free()
	globals.PlayerGold += 1000
	print("Settlement %s was raided")
	CurrentArea = ""

func _on_raid_button_button_up():
	$HUD/StatusInfo/RaidButton.visible = false
	
func _on_enter_button_pressed():
	get_tree().change_scene_to_file("res://city.tscn")



