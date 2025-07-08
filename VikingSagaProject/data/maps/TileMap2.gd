extends TileMap
@onready var globals = get_node("/root/Globals")
# Function to check if a tile is set at a specific grid position
func is_tile_set(x: int, y: int) -> bool:
	var cell_source_id = get_cell_source_id(0,Vector2i(x, y))
	return cell_source_id != -1

func _ready():
	pass
	
func _process(_delta):
	pass
