extends TileMap
@onready var globals = get_node("/root/Globals")
@onready var player = $"../TileMap/Player"
# Function to check if a tile is set at a specific grid position
func is_tile_set(x: int, y: int) -> bool:
	var cell_source_id = get_cell_source_id(0,Vector2i(x, y))
	return cell_source_id != -1

func _ready():
	pass
	
func _process(_delta):
	var tile_pos = $".".local_to_map(player.position)
	#print(tile_pos)
	#print_debug("processing animal map...")
	#if is_tile_set(globals.player_position.x,globals.player_position.y):
	if is_tile_set(tile_pos.x,tile_pos.y):
		var source_id = get_cell_source_id(0,Vector2i(tile_pos.x, tile_pos.y))
		if( source_id == null ):
			print_debug("source_id is null")
			return
		var _atlas_coord := get_cell_atlas_coords(source_id, Vector2i(0, 1))
		# SOME STRANGE BUG HERE
		var tile_source = tile_set.get_source(source_id)
		#print(tile_source)
		if( tile_source == null ):
			print_debug("tile_source is null")
			return
		var tile_data = tile_set.get_source(source_id).get_tile_data(Vector2i(0, 1),0)
		if( tile_data == null ):
			print_debug("tile_data is null")
			return
		# Animal Text output
		var custom_data = tile_data.get_custom_data("type")
		$"../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "ANIMALS: %s" % [custom_data]
		#print("There is a %s present here." % [custom_data])
	else:
		pass
