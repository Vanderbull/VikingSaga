extends CharacterBody2D

class_name Player
@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../../.."
@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtColor = $Sprite2D/ColorRect
@onready var hurtTimer = $hurtTimer
@onready var sound = %AudioStreamPlayer #$AudioStreamPlayer
@onready var soundAttack = %AudioStreamPlayer #$AudioStreamPlayer
@onready var worldMap = $".."
@onready var footstep_player = %FootstepPlayer #$FootstepPlayer
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
#var dynamic_array_instance = null
var time_since_last_step: float = 0.0

var warmth: float = 10000.0 # Player's warmth level
var near_fire: bool = false

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

# Warmth settings
var current_warmth: float = 100.0 # Max 100
var min_warmth: float = 0.0
var max_warmth: float = 100.0

# Rates of change (units per second)
var warmth_loss_rate: float = 5.0
var warmth_gain_rate: float = 10.0

# Environmental influence
var ambient_temperature: float = 5.0 # Celsius
var freezing_point: float = 0.0
# Player clothing (affects insulation)
var insulation_factor: float = 1.0 # 0 = no clothes, 2 = heavy coat

func check_if_quest_finished():
	if globals.quest_water >= globals.MAX_QUEST_WATER:
		if globals.quest_food >= globals.MAX_QUEST_FOOD:
			if globals.quest_wood >= globals.MAX_QUEST_WOOD:
				if globals.quest_clay >= globals.MAX_QUEST_CLAY:
					%QuestFinished.show()

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
	#$ActionButtons.hide()
	Warmth.set_insulation(1.5) # Player has medium clothing
	Warmth.set_ambient_temperature(5.0) # Cold biome
	if globals.character_position != Vector2.ZERO:
		position = globals.character_position
	# Load the DynamicArray script
	#var DynamicArrayScript = preload("res://dynamic_array.gd")
	# Create an instance of the DynamicArray script
	#dynamic_array_instance = DynamicArrayScript.new()	
	# Manually call _ready() to initialize the instance
	#dynamic_array_instance._ready()
	
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

	#var TileCoordinateText = dynamic_array_instance.find_coordinate_with_text(tile_pos.x,tile_pos.y)
	#$"../../../TileInfoWindow/PanelContainer/VBoxContainer/TileCoordinates".text = TileCoordinateText
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
			print("KEY_3 pressed")
			pass
		if event.pressed and event.keycode == KEY_4:
			print("KEY_4 pressed")
			pass
		if event.pressed and event.keycode == KEY_5:
			print("KEY_5 pressed")
			pass
		if event.pressed and event.keycode == KEY_6:
			print("KEY_6 pressed")
			pass
		if event.pressed and event.keycode == KEY_7:
			print("KEY_7 pressed")
			pass
		if event.pressed and event.keycode == KEY_8:
			print("KEY_8 pressed")
			pass
		if event.pressed and event.keycode == KEY_9:
			print("KEY_9 pressed")
			pass
		if event.pressed and event.keycode == KEY_0:
			print("KEY_0 pressed")
			pass
		if event.pressed and event.keycode == KEY_KP_0:
			print("KEY_KP_2 pressed")
		if event.pressed and event.keycode == KEY_KP_1:
			$"../../TileMap2".set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(1,2))
		if event.pressed and event.keycode == KEY_KP_2:
			print("KEY_KP_2 pressed")
		if event.pressed and event.keycode == KEY_KP_3:
			%QuestFinished.show()
		if event.pressed and event.keycode == KEY_KP_4:
			print("KEY_KP_4 pressed")
		if event.pressed and event.keycode == KEY_KP_5:
			print("KEY_KP_5 pressed")
		if event.pressed and event.keycode == KEY_KP_6:
			print("KEY_KP_6 pressed")
		if event.pressed and event.keycode == KEY_KP_7:
			print("KEY_KP_7 pressed")
		if event.pressed and event.keycode == KEY_KP_8:
			print("KEY_KP_8 pressed")
		if event.pressed and event.keycode == KEY_KP_9:
			print("KEY_KP_9 pressed")
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

func _process(delta):
	#$ActionButtons.show()
	if( globals.Terrain == "Water" ):
		ambient_temperature = -5.0
	else:
		ambient_temperature = 20.0
	check_if_quest_finished()
	#if globals.CollectClay:
		#if(!$DiggPlayer.is_audio_playing()):
			#$DiggPlayer.play()
	if( game_manager.playerData.Food < 0 || game_manager.playerData.Water < 0 ):
		get_tree().change_scene_to_file("res://scenes/gameover/gameover.tscn")
	game_manager.playerData.position = position

	handleInput()
	position = globals.character_position
	var _tile_pos = worldMap.local_to_map(position)
	# Assume tilemap is your TileMap node, and world_pos is a Vector2 world position
	var cell = $"..".local_to_map(position)
	var layer = 0

	var tile_data: TileData = $"..".get_cell_tile_data(layer, cell)
	if tile_data:
		var _terrain_type = tile_data.get_custom_data("terrain_type")
		#print("Terrain type:", terrain_type)
		var _movement_cost = tile_data.get_custom_data("movement_cost")
		#print("Movement cost:", movement_cost)
		move_and_slide()
		updateAnimation()
	
	var temperature_effect = ambient_temperature - freezing_point
	# Base warmth change
	var warmth_change = 0.0
	
	if near_fire:
		#current_warmth += warmth_gain_rate * delta  # Increase warmth while near fire
		warmth_change += warmth_gain_rate * delta
		#current_warmth = min(globals.Warmth, max_warmth)  # Cap warmth
	elif temperature_effect < 0.0:
		#current_warmth -= warmth_loss_rate * delta  # Decrease warmth when away from fire
		#current_warmth = max(globals.Warmth, min_warmth)  # Prevent it from going below zero
			warmth_change -= (abs(temperature_effect) / 10.0) * warmth_loss_rate * (1.0 / insulation_factor) * delta
	else:
		# Slight warmth gain in warm areas
		warmth_change += (temperature_effect / 30.0) * warmth_gain_rate * delta
	
	current_warmth = clamp(current_warmth + warmth_change, min_warmth, max_warmth)
	globals.Warmth = current_warmth

func _on_chop_player_finished():
	pass # Replace with function body.
	
func _on_animatedfire_warmth_effected(player: Variant) -> void:
	if player == self:
		near_fire = true
	else:
		near_fire = false

func _on_player_detection_area_area_entered(area: Area2D) -> void:
	# Check if the Area2D itself is in the "player" group (if you added PlayerDetectionArea to "player" group)
	if area.is_in_group("Animal"):
		print("Player hit by enemy animal attack!")
		print("Animal hit by player attack!")
		## Call a method on the player itself, like take_damage()
		XpManager.calculate_xp_for_level(globals.level)
		XpManager.increase_experience(globals.experience,100,globals.level)
		area.get_parent().queue_free()
	elif area.is_in_group("Npc"):
		print("Player hit by enemy npc attack!")
		print("Npc hit by player attack!")
		## Call a method on the player itself, like take_damage()
		XpManager.calculate_xp_for_level(globals.level)
		XpManager.increase_experience(globals.experience,100,globals.level)
		area.get_parent().queue_free()

	#elif area.is_in_group("collectible"):
		#print("Player picked up a collectible!")
		#area.queue_free() # Remove the collectible
