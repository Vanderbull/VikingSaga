extends CharacterBody2D

class_name Player
@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../../.."
@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtColor = $Sprite2D/ColorRect
@onready var hurtTimer = $hurtTimer
@onready var sound = $AudioStreamPlayer2D
@onready var soundAttack = $AudioStreamPlayer
@onready var worldMap = $".."
@onready var footstep_player = $FootstepPlayer
@onready var chop_player = $ChopPlayer
@onready var digg_player = $DiggPlayer
@export var speed: int = 16
@export var footstep_interval: float = 0.1
@export var walking_sounds: Array[AudioStream]  # List of footstep sounds
# Chopping wood
@export var chop_sounds: Array[AudioStream]  # List of wood choping sounds
# Digg clay
@export var digg_sounds: Array[AudioStream]  # List of wood choping sounds
# Reference to the DynamicArray script
var dynamic_array_instance = null
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
		await chop_player.finished
		
func play_digg_sound() -> void:
	if(digg_player.is_audio_playing()):
		digg_player.play()

func _input(event):
	pass

func _ready():
	# Load the DynamicArray script
	var DynamicArrayScript = preload("res://dynamic_array.gd")
	# Create an instance of the DynamicArray script
	dynamic_array_instance = DynamicArrayScript.new()	
	# Manually call _ready() to initialize the instance
	dynamic_array_instance._ready()
	
	$Camera2D.zoom.x = 6.00
	$Camera2D.zoom.y = 6.00
	velocity = Vector2i(0,0)
	globals.Walking = false
	effects.play("RESET")

func handleInput():
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
	if globals.ForestCutting:
		globals.ForestCutting = not globals.ForestCutting
	
	var tile_pos = worldMap.local_to_map(position)
	globals.player_position = tile_pos
	
	#if( globals.Animals == "Rabbit" ):
		#$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "ANIMALS: Rabbit"
	#	$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "ANIMALS: Rabbit"
	#else:
	#	$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "ANIMALS: None"
		
	if( globals.Terrain == "Forest" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Forest"
	if( globals.Terrain == "Sand" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Sand"
	if( globals.Terrain == "Water" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Water"
	if( globals.Terrain == "Grass" ):
		$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Grass"

	var TileCoordinateText = dynamic_array_instance.find_coordinate_with_text(tile_pos.x,tile_pos.y)
	$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileCoordinates".text = TileCoordinateText
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_1:
			globals.RoadWorks = not globals.RoadWorks
		if event.pressed and event.keycode == KEY_2:
			if( globals.Animals != -1 ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.Hunting = not globals.Hunting
				var atlas_coords = Vector2i(0, 0)
				var tilemap = $"../../AnimalMap"
				tilemap.set_cell(0,tile_pos, -1)
				globals.ForestCutting = false
			elif( globals.Terrain == "Sand" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.DigSand = not globals.DigSand
			elif( globals.Terrain == "Forest" ):
				$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileType".text = "TileType: Forest"
				if $"../../TileMap2".is_tile_set(tile_pos.x, tile_pos.y):
					print(" THERE IS NO MORE TREESS")
				else:
					$"../../../InGameCanvasLayer/ProgressBar".show()
					globals.ForestCutting = not globals.ForestCutting
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
	if globals.CollectClay:
		if(!$DiggPlayer.is_audio_playing()):
			$DiggPlayer.play()
	if( game_manager.playerData.PlayerFood < 0 || game_manager.playerData.PlayerWater < 0 ):
		get_tree().reload_current_scene()
	game_manager.playerData.player_position = position
	_delta = 0.00000000000
	handleInput()
	move_and_slide()
	updateAnimation()

func _on_chop_player_finished():
	pass # Replace with function body.
