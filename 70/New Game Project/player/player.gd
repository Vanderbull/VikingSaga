extends CharacterBody2D

class_name Player

signal healthChanged
signal healthChangedShip
signal healthChangedVillage

@export var speed: int = 300
@export var Identity = "Player"

@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtColor = $Sprite2D/ColorRect
@onready var hurtTimer = $hurtTimer
@onready var sound = $AudioStreamPlayer2D
@onready var soundAttack = $AudioStreamPlayer

@export var MaxHealth = 10
@onready var CurrentHealth: int = MaxHealth
@export var knockbackPower: int  = 500

@export_enum("VIKING", "MARAUDER", "SHIELDMAIDEN") var character_class: int

@export_flags("Fire", "Water", "Earth", "Wind") var spell_elements = 0
@onready var gold = 0
@onready var warriors = 0
@onready var farmers = 0
@onready var thralls = 0
@onready var hides = 0

var walking = false

#var target = position #Vector2(544,544) is zero

@onready var globals = get_node("/root/Globals")

func _ready():
	$Identity.text = Identity
	#print_debug("READY THE PLAYER AGAIN")
	effects.play("RESET")
	#print(position)
	#target = position

func handleInput():
	var moveDirection = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#print(moveDirection)
	velocity = moveDirection*speed
	
	
func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
			walking = false
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		animations.play("walk" + direction)
		walking = true
		
#func _input(event):
#	if event.is_action_pressed("click"):
#		target = get_global_mouse_position()
		
func _physics_process(_delta):
	$Identity.text = Identity
	#velocity = position.direction_to(target) * speed
	# look_at(target)
	#if position.distance_to(target) > 10:
	#	move_and_slide()
	globals.player_position = position
	handleInput()
	move_and_slide()
	#handleCollision()
	updateAnimation()
	if walking:
		if !sound.playing:
			sound.play()
	else:
		sound.stop()


func _on_hurt_box_area_entered(area):
	if area.name == "villageHitbox":
		area.get_parent().hp -= 1
		healthChangedVillage.emit(area.get_parent().hp)
		if area.get_parent().hp <= 0:
			gold += 10
			area.get_parent().queue_free()
		CurrentHealth -= 1
		healthChanged.emit(CurrentHealth)
		soundAttack.play()
		var knockbackDirection = (-velocity).normalized() * knockbackPower
		var knockbacked = knockbackDirection
		velocity = knockbacked
		move_and_slide()

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
		CurrentHealth -= 1
		if CurrentHealth < 0:
			get_tree().change_scene_to_file("res://3d/3d.tscn")
			#CurrentHealth = MaxHealth
			
		healthChanged.emit(CurrentHealth)
		knockback(area.get_parent().velocity)
		effects.play("hurtBlink")
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		soundAttack.play()

func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()


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
