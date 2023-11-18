extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint = Marker2D
@export var Identity = "Enemy"

@onready var animations = $AnimationPlayer
@onready var sound = $AudioStreamPlayer2D
@onready var hp = 5

var StartPosition
var EndPosition

func _ready():
	StartPosition = position
	EndPosition = endPoint.global_position
	$Identity.text = Identity

func changeDirection():
	var tempEnd = EndPosition
	EndPosition = StartPosition
	StartPosition = tempEnd
		
func updateVelocity():
	var moveDirection = EndPosition - position
	if moveDirection.length() < limit:
		changeDirection()
				
	velocity = moveDirection.normalized()*speed

func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		animations.play("walk" + direction)
		
func _physics_process(_delta):
	$Identity.text = Identity
	updateVelocity()
	move_and_slide()
	updateAnimation()
	if !sound.playing:
		sound.play()
