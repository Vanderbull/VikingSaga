extends CharacterBody2D

class_name Player
@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../../.."
@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtColor = $Sprite2D/ColorRect
@onready var hurtTimer = $hurtTimer
@onready var sound = $AudioStreamPlayer
@onready var soundAttack = $AudioStreamPlayer
@onready var worldMap = $".."
@onready var footstep_player = $FootstepPlayer
@onready var chop_player = $ChopPlayer
@onready var digg_player = $DiggPlayer
#@onready var game_over_scene = $"../../../GameOver"
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

var warmth: float = 10000.0 # Player's warmth level
var near_fire: bool = false

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

func check_if_quest_finished():
	if globals.QuestWater >= 10000:
		if globals.QuestFood >= 10000:
			if globals.QuestTrees >= 10000:
				if globals.QuestClay >= 10000:
					$"../../../QuestFinished/QuestFinished".show()

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
		#var sound = walking_sounds[randi() % walking_sounds.size()]
		#footstep_player.stream = sound
		footstep_player.stream = walking_sounds[randi() % walking_sounds.size()]
		footstep_player.play()
		
func play_chop_sound() -> void:
	if chop_sounds.size() > 0:
		#var sound = chop_sounds[randi() % chop_sounds.size()]
		#chop_player.stream = sound
		chop_player.stream = chop_sounds[randi() % chop_sounds.size()]
		chop_player.play()
		await chop_player.finished
		
func play_digg_sound() -> void:
	if(digg_player.is_audio_playing()):
		digg_player.play()

func _input(_event):
	pass

func _ready():
	if globals.character_position != Vector2.ZERO:
		position = globals.character_position
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
	if Input.is_action_just_pressed("ui_accept"):
		#DialogueManager.show_example_dialogue_balloon(load("res://dialogue/dialogue.dialogue"),"start")
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/viking_dialogue.dialogue"),"start")
		return
	var tile_pos = worldMap.local_to_map(position)
	#globals.player_position = tile_pos
	#globals.player_position = tile_pos
	
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
			#if( globals.Animals != -1 ):
				#$"../../../InGameCanvasLayer/ProgressBar".show()
				#globals.Hunting = not globals.Hunting
				##var atlas_coords = Vector2i(0, 0)
				#var tilemap = $"../../AnimalMap"
				#tilemap.set_cell(0,tile_pos, -1)
			if( globals.Terrain == "Sand" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.DigSand = not globals.DigSand
			elif( globals.Terrain == "Forest" ):
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
		if event.pressed and event.keycode == KEY_KP_1:
			$"../../TileMap2".set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(1,2))
		#if event.pressed and event.keycode == KEY_KP_2:
			#$"../../../Control"._show_popup_with_typing()
		if event.pressed and event.keycode == KEY_KP_3:
			$"../../../QuestFinished/QuestFinished".show()
			
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$Camera2D.zoom += Vector2(zoom_speed, zoom_speed)
				#$Camera2D.zoom.x += 0.25
				#$Camera2D.zoom.y += 0.25
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$Camera2D.zoom -= Vector2(zoom_speed, zoom_speed)
				#$Camera2D.zoom.x -= 0.25
				#$Camera2D.zoom.y -= 0.25
			$Camera2D.zoom = $Camera2D.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func check_for_water():
	var left = -16
	var right = 16
	var up = -16
	var down = 16
	
	var position_temp = globals.character_position
	print(position_temp)
	var tile_position = worldMap.local_to_map(position_temp)
	print(tile_position)
	var tile_pos_modified = worldMap.local_to_map(position_temp + Vector2(left,0))
	print(tile_pos_modified)
		
	tile_pos_modified = worldMap.local_to_map(position_temp + Vector2(left,0))
	$"..".get_terrain_type(tile_pos_modified.x, tile_pos_modified.y)
	print(globals.Terrain)
	tile_pos_modified = worldMap.local_to_map(position_temp + Vector2(right,0))
	$"..".get_terrain_type(tile_pos_modified.x, tile_pos_modified.y)
	print(globals.Terrain)
	tile_pos_modified = worldMap.local_to_map(position_temp + Vector2(up,0))
	$"..".get_terrain_type(tile_pos_modified.x, tile_pos_modified.y)
	print(globals.Terrain)
	tile_pos_modified = worldMap.local_to_map(position_temp + Vector2(down,0))
	$"..".get_terrain_type(tile_pos_modified.x, tile_pos_modified.y)
	print(globals.Terrain)
		
	#print(tile_pos)
	#if( $"..".get_terrain_type(tile_pos.x, tile_pos.y) == "Water"):
		#print("WATER")
	#else:
		#print("LAND")
	return

func _process(delta):
	check_if_quest_finished()
	if globals.CollectClay:
		if(!$DiggPlayer.is_audio_playing()):
			$DiggPlayer.play()
	if( game_manager.playerData.Food < 0 || game_manager.playerData.Water < 0 ):
		get_tree().change_scene_to_file("res://game_over.tscn")
		#get_tree().reload_current_scene()
	game_manager.playerData.position = position
	#delta = 0.00000000000

	handleInput()
	position = globals.character_position
	var tile_pos = worldMap.local_to_map(position)
	#print(tile_pos)
	# velocity 300 needs to be changed to tile positions
	#print(velocity)
	move_and_slide()
	updateAnimation()
		
	check_for_water()
	if near_fire:
		globals.Warmth += 10.0 * delta  # Increase warmth while near fire
		globals.Warmth = min(globals.Warmth, 100)  # Cap warmth
	else:
		if velocity == Vector2(0,0):
			globals.Warmth -= 5.0 * delta  # Decrease warmth when away from fire
		globals.Warmth = max(globals.Warmth, 0)  # Prevent it from going below zero
	print(velocity)

func _on_chop_player_finished():
	pass # Replace with function body.
	
func _on_animatedfire_warmth_effected(player: Variant) -> void:
	if player == self:
		near_fire = true
	else:
		near_fire = false
