extends Resource
class_name PlayerData

@export var health = 100

func  change_health(value: int):
	health += value
