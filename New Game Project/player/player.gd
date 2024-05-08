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

var walking = false

@onready var worldMap = $".."

func _ready():
	$Camera2D.zoom.x = 6.00
	$Camera2D.zoom.y = 6.00
	walking = false
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
			walking = false
			globals.Walking = false
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		animations.play("walk" + direction)
		walking = true
		globals.Walking = true
		
func _unhandled_input(event):
	var tile_pos = worldMap.local_to_map(position)
	#worldMap.set_cell(0, Vector2i(tile_pos.x, tile_pos.y - 1), 0 ,Vector2i(25,14))
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_1:
			globals.RoadWorks = not globals.RoadWorks
		if event.pressed and event.keycode == KEY_2:
			if( globals.Terrain == "Sand" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.DigSand = not globals.DigSand
			if( globals.Terrain == "Forest" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.ForestCutting = not globals.ForestCutting
			if( globals.Terrain == "Water" ):
				$"../../../InGameCanvasLayer/ProgressBar".show()
				globals.CollectWater = not globals.CollectWater
				
		if event.pressed and event.keycode == KEY_3:
			# Burn some wood
			pass
		
		if event.pressed and event.keycode == KEY_4:
			get_tree().change_scene_to_file("res://src/battle.tscn")
				
		if event.pressed and event.keycode == KEY_Z:
			$Camera2D.zoom.x += 0.25
			$Camera2D.zoom.y += 0.25
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				print("up")
				$Camera2D.zoom.x += 0.25
				$Camera2D.zoom.y += 0.25
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				print("down")
				$Camera2D.zoom.x -= 0.25
				$Camera2D.zoom.y -= 0.25
		
		
func _process(_delta):
	if( game_manager.playerData.PlayerFood < 0 ):
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
	print_debug(area)
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
	print_debug(area)
	if area.name == "villageHitbox":
		print_debug("WOW WOW WOW WOW")
		var root = get_tree().get_root()
		for child in root.get_children():
			var StatsBox = child.find_child("BottomLeftPanel")
			if StatsBox != null:
				StatsBox.visible = false
				pass
