extends CharacterBody2D

@onready var path_follow = get_parent()
@onready var path_2d = $"../.."

@onready var hp = 10

@export var speed = 250.0
@export var path_progress = 0.0
@export var waypoint = 0
@export var distance_left = 0
@export var wake = 0
@export var testing = 0
@export var MoveShip = false
@export var ReturnShip = false

signal healthChanged
signal healthChangedShip
signal healthChangedVillage

func distance(first_vector, second_vector):
	distance_left = sqrt(pow((first_vector.y - second_vector.y),2) + pow((first_vector.x - second_vector.x),2))
	return distance_left
	
func _ready():
	distance(path_2d.curve.sample(1,0.0), path_2d.curve.sample(2,0.0))
	#hp -= 1
	healthChangedShip.emit(4)

func _process(_delta):
	$"../../../Line2D".add_point(global_position)
	while $"../../../Line2D".get_point_count() > 100:
		$"../../../Line2D".remove_point(0)

# Distance between two points = √(xB−xA)2+(yB−yA)2
func _physics_process(delta):
	distance_left -= speed * delta
	if distance_left <= 0:
		distance(path_2d.curve.sample(waypoint,0.0), path_2d.curve.sample(waypoint+1,0.0))
		#print_debug("Past " + str(waypoint) + " checkpoint")
		if waypoint < path_2d.curve.point_count - 1:
			waypoint += 1
		else:
			waypoint = 0
	#$"../../../../PathProgress".global_position = global_position
	if MoveShip:
		path_progress += speed * delta
		path_follow.set_progress(path_progress)
		$"../../../Player".set_collision_layer_value(1,false)
		$"../../../Player".set_collision_mask_value(1,false)
		$"../../../Player".position = global_position
		if path_follow.get_progress_ratio() == 1.0:
			MoveShip = false
			$"../../../Player".position.y += 100
			$"../../../Player".set_collision_layer_value(1,true)
			$"../../../Player".set_collision_mask_value(1,true)
		#if path_follow.get_progress_ratio() == 1.0 :
		#	path_progress -= speed * delta
		#	$"../../../Player".position.y += 100
		#	$"../../../Player".set_collision_layer_value(1,true)
		#	$"../../../Player".set_collision_mask_value(1,true)
		#MoveShip = false
	#if path_progress > 1725 and MoveShip:
	#	ReturnShip = true
	#	MoveShip = false
	#	$"../../../Player".set_collision_layer_value(1,true)
	#	$"../../../Player".set_collision_mask_value(1,true)
	#	print_debug("Reached destination")
	#	rotate(3.1415926536)
	#if ReturnShip:
	#	path_progress -= speed * delta
	#	path_follow.set_progress(path_progress)
	#if path_progress <= 0:
	#	ReturnShip = false
		#$"../../../Player".position.x += 100
		# path_follow.set_offset(path_follow.get.get_offset() + speed * delta)
	if ReturnShip:
		path_progress -= speed * delta
		path_follow.set_progress(path_progress)
		$"../../../Player".set_collision_layer_value(1,false)
		$"../../../Player".set_collision_mask_value(1,false)
		$"../../../Player".position = global_position
		if path_follow.get_progress_ratio() == 0.0:
			ReturnShip = false
			$"../../../Player".position.y += 100
			$"../../../Player".set_collision_layer_value(1,true)
			$"../../../Player".set_collision_mask_value(1,true)
