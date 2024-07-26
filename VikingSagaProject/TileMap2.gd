extends TileMap

# Function to check if a tile is set at a specific grid position
func is_tile_set(x: int, y: int) -> bool:
	var cell_source_id = get_cell_source_id(0,Vector2i(x, y))
	return cell_source_id != -1

# Example usage in a script where this TileMap is referenced
func _ready():
	var x = 2
	var y = 3
	if is_tile_set(x, y):
		print("Tile is set at position (", x, ", ", y, ")")
	else:
		print("No tile is set at position (", x, ", ", y, ")")
