extends Node

var ready_already = true
var player_position = Vector2(0,0)
var cloud_position = Vector2(100,100)

var RoadWorks = false
var ForestCutting = false
var DigSand = false
var CollectWater = false
var CollectClay = false
var Hunting = false


var Terrain = "None"
var Animals = "None"

var Walking = false

var level = 1

var experience = 0
var experience_total = 0
var experience_required = get_required_experience(level + 1)

func get_required_experience(level):
	return round(pow(level, 1.8) + level * 4)

func gain_experience(amount):
	experience_total += amount
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()
		
func level_up():
	level += 1
	experience_required = get_required_experience(level +1)
	
