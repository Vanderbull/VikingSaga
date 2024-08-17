extends TileMap
@onready var globals = get_node("/root/Globals")
# Function to check if a tile is set at a specific grid position
func is_tile_set(x: int, y: int) -> bool:
	var cell_source_id = get_cell_source_id(0,Vector2i(x, y))
	return cell_source_id != -1

# Example usage in a script where this TileMap is referenced
func _ready():
	pass
	
func _process(delta):
	#print(globals.player_position)
	if is_tile_set(globals.player_position.x,globals.player_position.y):
		print("WARMTH HERE")
		if globals.Warmth < 100:
			globals.Warmth += 1
	else:
		if( globals.Warmth > 0 ):
			globals.Warmth -= 1
		pass
		#print("No tile is set at position (", x, ", ", y, ")")
