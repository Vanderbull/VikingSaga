extends CharacterBody2D

class_name Player

signal healthChanged
signal healthChangedShip
signal healthChangedVillage

@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../../.."

@export var speed: int = 16

@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtColor = $Sprite2D/ColorRect
@onready var hurtTimer = $hurtTimer
@onready var sound = $AudioStreamPlayer2D
@onready var soundAttack = $AudioStreamPlayer

@export_enum("VIKING", "MARAUDER", "SHIELDMAIDEN") var character_class: int

@export_flags("Fire", "Water", "Earth", "Wind") var spell_elements = 0
@onready var gold = 1000
@onready var warriors = 1000
@onready var farmers = 1000
@onready var thralls = 1000
@onready var hides = 1000

#var walking = false

@onready var worldMap = $".."

# Reference to the DynamicArray script
var dynamic_array_instance = null

@export var footstep_interval: float = 0.1
@export var walking_sounds: Array[AudioStream]  # List of footstep sounds

@onready var footstep_player = $FootstepPlayer

# Chopping wood
@export var chop_sounds: Array[AudioStream]  # List of wood choping sounds
@onready var chop_player = $ChopPlayer

var time_since_last_step: float = 0.0

func _physics_process(delta: float) -> void:
	# Check if the player is moving
	if velocity.length() > 0:
		time_since_last_step += delta
		if time_since_last_step >= footstep_interval:
			play_footstep_sound()
			time_since_last_step = 0.0
	else:
		time_since_last_step = footstep_interval  # Reset when not moving
		
	

func play_footstep_sound() -> void:
	if walking_sounds.size() > 0:
		var sound = walking_sounds[randi() % walking_sounds.size()]
		footstep_player.stream = sound
		footstep_player.play()
		
func play_chop_sound() -> void:
	if chop_sounds.size() > 0:
		var sound = chop_sounds[randi() % chop_sounds.size()]
		chop_player.stream = sound
		chop_player.play()
		print("sound ALOT!!!")
		await chop_player.finished

func _input(event):
	if not event.is_action_pressed("ui_accept"):
		return
	globals.gain_experience(50)
	$"../../../Interface/Label".update_text(globals.level, globals.experience, globals.experience_required)

func _ready():
	# Load the DynamicArray script
	var DynamicArrayScript = preload("res://dynamic_array.gd")
	# Create an instance of the DynamicArray script
	dynamic_array_instance = DynamicArrayScript.new()
	
	# Add the dynamic array node to the scene tree if needed
	# add_child(dynamic_array_instance)
	
	# Manually call _ready() to initialize the instance
	dynamic_array_instance._ready()
	
	# Add new elements to the dynamic array
	#dynamic_array_instance.add_element(40)
	#dynamic_array_instance.add_element(50)
	
	# Print the updated array contents
	#dynamic_array_instance.print_array()

	$Camera2D.zoom.x = 6.00
	$Camera2D.zoom.y = 6.00
	velocity = Vector2i(0,0)
	globals.Walking = false
	effects.play("RESET")

func handleInput():
	#if $"../../../Quests/VBoxContainer/Clock".get_timeofday() == "NIGHT":
		#$"../../../Control"._show_popup()
	#else:
		var moveDirection = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
		velocity = moveDirection*speed
	
func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
			globals.Walking = false
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		animations.play("walk" + direction)
		globals.Walking = true
		
func _unhandled_input(event):

	if( globals.Animals == "Rabbit" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "ANIMALS: Rabbit"
	else:
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "ANIMALS: None"
		
	if( globals.Terrain == "Forest" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Forest"
	if( globals.Terrain == "Sand" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Sand"
	if( globals.Terrain == "Water" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Water"
	if( globals.Terrain == "Grass" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Grass"
		
	var tile_pos = worldMap.local_to_map(position)
	globals.player_position = tile_pos
	#print_debug(tile_pos)
	#print(dynamic_array_instance.find_coordinate_with_text(tile_pos.x,tile_pos.y))
	var TileCoordinateText = dynamic_array_instance.find_coordinate_with_text(tile_pos.x,tile_pos.y)
	$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileCoordinates".text = TileCoordinateText
	#worldMap.set_cell(0, Vector2i(tile_pos.x, tile_pos.y - 1), 0 ,Vector2i(25,14))
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_1:
			globals.RoadWorks = not globals.RoadWorks
		if event.pressed and event.keycode == KEY_2:
			# Add some kind of amount for the tile and decrease that until zero and then change the tile type according to some matrix
			# add some kind of window with all the tile information in
			if( globals.Animals == "Rabbit" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.Hunting = not globals.Hunting
				var atlas_coords = Vector2i(0, 0)
				var tilemap = $"../../AnimalMap"
				tilemap.set_cell(0,tile_pos, -1)
			elif( globals.Terrain == "Sand" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.DigSand = not globals.DigSand
			elif( globals.Terrain == "Forest" ):
				$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Forest"
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.ForestCutting = not globals.ForestCutting
				if globals.ForestCutting == true:
					play_chop_sound()
			elif( globals.Terrain == "Water" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.CollectWater = not globals.CollectWater
			elif( globals.Terrain == "Grass" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.CollectClay = not globals.CollectClay
		if event.pressed and event.keycode == KEY_3:
			# Burn some wood
			pass		
		if event.pressed and event.keycode == KEY_4:
			get_tree().change_scene_to_file("res://src/battle.tscn")
		if event.pressed and event.keycode == KEY_KP_1:
			$"../../TileMap2".set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(1,2))
		if event.pressed and event.keycode == KEY_KP_2:
			$"../../../Control"._show_popup_with_typing()
			
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$Camera2D.zoom.x += 0.25
				$Camera2D.zoom.y += 0.25
				print_debug("Zoom (X: ", $Camera2D.zoom.x, " | Y: ",  $Camera2D.zoom.y, ")")
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$Camera2D.zoom.x -= 0.25
				$Camera2D.zoom.y -= 0.25
				print_debug("Zoom (X: ", $Camera2D.zoom.x, " | Y: ", $Camera2D.zoom.y, ")")
		
		
func _process(_delta):
	if( game_manager.playerData.PlayerFood < 0 || game_manager.playerData.PlayerWater < 0 ):
		get_tree().reload_current_scene()
	game_manager.playerData.player_position = position
	#position.x += 1
	_delta = 0.00000000000
	#velocity = position.direction_to(target) * speed
	# look_at(target)
	#if position.distance_to(target) > 10:
	#	move_and_slide()
	#globals.player_position = position

	handleInput()
	#print(velocity)
	move_and_slide()
	#handleCollision()
	updateAnimation()

func _on_hurt_box_area_entered(area):
	if area.name == "villageHitbox":
		area.get_parent().hp -= 1
		healthChangedVillage.emit(area.get_parent().hp)
		if area.get_parent().hp <= 0:
			gold += 10
			area.get_parent().queue_free()
		#CurrentHealth -= 1
		#healthChanged.emit(CurrentHealth)
		soundAttack.play()
		#var knockbackDirection = (-velocity).normalized() * knockbackPower
		#var knockbacked = knockbackDirection
		#velocity = knockbacked
		#move_and_slide()

	if area.name == "shipHitbox":
		if $"../Path2D/PathFollow2D/Ship".visible:
			area.get_parent().hp -= 1
			gold -= 1
			healthChangedShip.emit(area.get_parent().hp)
			if $"../Path2D/PathFollow2D".get_progress_ratio() == 0.0:
				$"../Path2D/PathFollow2D/Ship".MoveShip = true
			if $"../Path2D/PathFollow2D".get_progress_ratio() == 1.0:
				$"../Path2D/PathFollow2D/Ship".ReturnShip = true
		
	if area.name == "hitBox":
		area.get_parent().hp -= 1
		if area.get_parent().hp <= 0:
			area.get_parent().queue_free()
		#CurrentHealth -= 1
		#if CurrentHealth < 0:
			#get_tree().change_scene_to_file("res://3d/3d.tscn")
			#CurrentHealth = MaxHealth
			
		#healthChanged.emit(CurrentHealth)
		knockback(area.get_parent().velocity)
		effects.play("hurtBlink")
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		soundAttack.play()

func knockback(enemyVelocity: Vector2):
	#var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	#velocity = knockbackDirection
	#move_and_slide()
	pass


func _on_show_stats_box_area_entered(area):
	#print_debug(area)
	if area.name == "hitBox":
		if area.get_parent().Identity == "Slime2":
			print(area.get_parent().Identity)
	#if area.name == "hitBox":
	#	print(area.get_parent().Identity)
	if area.name == "villageHitbox":
		if area.get_parent().Identity == "Village":
			print("YOU ARE ENTERING YOUR OWN VILLAGE")
		var root = get_tree().get_root()
		for child in root.get_children():
			var StatsBox = child.find_child("BottomLeftPanel")
			if StatsBox != null:
				StatsBox.visible = true
				get_tree().change_scene_to_file("res://city.tscn")


func _on_show_stats_box_area_exited(area):
	#print_debug(area)
	if area.name == "villageHitbox":
		#print_debug("WOW WOW WOW WOW")
		var root = get_tree().get_root()
		for child in root.get_children():
			var StatsBox = child.find_child("BottomLeftPanel")
			if StatsBox != null:
				StatsBox.visible = false
				pass
