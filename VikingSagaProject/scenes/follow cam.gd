extends Camera2D

@export var tilemap: TileMap

func _ready():
	var _mapRect = tilemap.get_used_rect()
