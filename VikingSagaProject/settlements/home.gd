extends Area2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint = Marker2D
@export var Identity = "Village"

#@onready var animations = $AnimationPlayer
@onready var hp = 6

func _ready():
	$Identity.text = Identity

func _physics_process(_delta):
	$Identity.text = Identity
