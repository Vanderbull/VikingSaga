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
	$HUD.visible = true
	
	$HUD/BottomRightPanel/WaterProgressBar.max_value = globals.PlayerWater
	$HUD/BottomRightPanel/FoodProgressBar.max_value = globals.PlayerFood
	$HUD/BottomRightPanel/WaterProgressBar.value = globals.PlayerWater
	$HUD/BottomRightPanel/FoodProgressBar.value = globals.PlayerFood
	ship.speed = globals.PlayerShipSpeed
	print("ARE WE LOADING THIS")
	$HUD/StatusInfo/Label.visible = false
	$HUD/StatusInfo/EnterButton.visible = false
	$HUD/StatusInfo/RaidButton.visible = false
	$TileMap/Path2D/PathFollow2D/Ship.visible = false
	
	$HUD/BottomRightPanel/HBoxContainer/PlayerGold.text = "Gold: " + str(0)
	$HUD/BottomRightPanel/HBoxContainer/PlayerThralls.text = "Thralls: " + str(0)
	$HUD/BottomRightPanel/HBoxContainer/PlayerHides.text = "Hides: " + str(0)
	$HUD/BottomRightPanel/HBoxContainer/PlayerWarriors.text = "Warriors: " + str(0)
	$HUD/BottomRightPanel/HBoxContainer/PlayerFarmers.text = "Farmers: " + str(0)
	
	pass
	ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
	var enemy_scene = ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH)
	enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.hide()
	
	if globals.ready_already:
		#globals.player_position = player.position
		heartsContainer.setMaxHearts(player.MaxHealth)
		heartsContainer.updateHearts(player.CurrentHealth)
		#heartsContainer2.setMaxHearts(ship.hp)
		#heartsContainer2.updateHearts(ship.hp)
		player.healthChanged.connect(heartsContainer.updateHearts)
		#player.healthChangedShip.connect(heartsContainer2.updateHearts)
		heartsContainer2.setMaxHearts(ship.hp)
		heartsContainer2.updateHearts(ship.hp)
		player.healthChangedShip.connect(heartsContainer2.updateHearts)
		$PathProgress.text = str($TileMap/Path2D/PathFollow2D.progress)
		#camera.limit_bottom = 1010
		#$HUD/Viewport.text = str(camera.get_viewport_rect())
		#$HUD/BottomRightPanel/Gold.text = "Gold: " + str(globals.PlayerGold)
		globals.ready_already = false
	else:
		pass
		#player.position = globals.player_position


func _process(_delta):
	var time = Time.get_time_dict_from_system()

	# we can use format strings to pad it to a length of 2 with zeros, e.g. 01:20:12
	#print("%02d:%02d:%02d" % [time.hour, time.minute, time.second])
	$HUD/Time.text = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	if globals.PlayerFood < 0.0 or globals.PlayerWater < 0.0:
		get_tree().change_scene_to_file("res://3d/3d.tscn")
	if player.velocity.x != 0.0 or player.velocity.y != 0.0:
		globals.PlayerFood -= 0.1
		globals.PlayerWater -= 0.1
		$HUD/BottomRightPanel/WaterProgressBar.value = globals.PlayerWater
		$HUD/BottomRightPanel/FoodProgressBar.value = globals.PlayerFood
		#$HUD/BottomRightPanel/HBoxContainer/PlayerFood.text = "Food: " + str(globals.PlayerFood)
		#$HUD/BottomRightPanel/HBoxContainer/PlayerWater.text = "Water: " + str(globals.PlayerWater)
	PlayerGridPosition = player.global_position / 16
	var PlayerTileData = $TileMap.get_cell_tile_data ( 1, PlayerGridPosition.round())
	if PlayerTileData != null:
		if PlayerTileData.get_custom_data("Tree"):
			globals.PlayerWood+=1
			$TileMap.erase_cell( 1 , PlayerGridPosition.round() )
			print(str(globals.PlayerWood))
		#print_debug("Terrain: " + str(PlayerTileData))	
		#print(PlayerGridPosition.round())
		#var tilemap = get_node("TileMap")
		#var named_tile = tilemap.get_layer_name(1)
		#print(named_tile)
	var root = get_tree().get_root()
	
	$HUD/BottomRightPanel/HBoxContainer/PlayerGold.text = "Gold: " + str(globals.PlayerGold)
	$HUD/BottomRightPanel/HBoxContainer/PlayerThralls.text = "Thralls: " + str(globals.PlayerThralls)
	$HUD/BottomRightPanel/HBoxContainer/PlayerHides.text = "Hides: " + str(globals.PlayerHides)
	$HUD/BottomRightPanel/HBoxContainer/PlayerWarriors.text = "Warriors: " + str(globals.PlayerWarriors)
	$HUD/BottomRightPanel/HBoxContainer/PlayerFarmers.text = "Farmers: " + str(globals.PlayerFarmers)
	$HUD/BottomRightPanel/HBoxContainer/PlayerWood.text = "Wood: " + str(globals.PlayerWood)
	
	$PathProgress.text = str($TileMap/Path2D/PathFollow2D.progress)

	for child in root.get_children():
		var slimet = child.find_child("slime")
		if slimet != null:
			$TileMap/slime/HP.text = str(slime.hp)

	for child in root.get_children():
		var slimet = child.find_child("slime2")
		if slimet != null:
			$TileMap/slime2/HP.text = str(slime2.hp)
			
	for child in root.get_children():
		var world_villagen = child.find_child("world_village")
		if world_villagen != null:
			pass
			#$TileMap/world_village/HP.text = str(world_villagen.hp)
	if $TileMap/Path2D/PathFollow2D/Ship.visible == false:
		if globals.PlayerShip:
			$TileMap/Path2D/PathFollow2D/Ship.visible = true

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_1:
			if globals.PlayerGold >= 1:
				globals.PlayerGold -= 1
				player.CurrentHealth = 10
				heartsContainer.updateHearts(10)
		if event.pressed and event.keycode == KEY_2:
			if globals.playerGold >= 1:
				globals.PlayerGold -= 1
				ship.hp = 10
				heartsContainer2.updateHearts(ship.hp)
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
	pass # Replace with function body.

func _on_forest_body_exited(_body):
	PlayerCuttingTrees = false
	pass # Replace with function body.

func _on_quest_area_body_entered(_body):
	#$QuestCanvasLayer/Control/ItemList.add_item("FIND A DONKEY")
	$TileMap/QuestArea.queue_free()
	pass # Replace with function body.

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
	pass # Replace with function body.

func _on_raid_button_button_up():
	$HUD/StatusInfo/RaidButton.visible = false
	pass # Replace with function body.
	
func _on_enter_button_pressed():
	get_tree().change_scene_to_file("res://city.tscn")
	pass # Replace with function body.



