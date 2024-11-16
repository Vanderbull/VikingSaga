extends TileMap
@onready var globals = get_node("/root/Globals")
# Function to check if a tile is set at a specific grid position
func is_tile_set(x: int, y: int) -> bool:
	var cell_source_id = get_cell_source_id(0,Vector2i(x, y))
	return cell_source_id != -1

# Example usage in a script wherWolfe this TileMap is referenced
func _ready():
	pass
	
func _process(delta):
	if is_tile_set(globals.player_position.x,globals.player_position.y):
		var source_id = get_cell_source_id(0,Vector2i(globals.player_position.x, globals.player_position.y))
		if( source_id == null ):
			return
		var atlas_coord := get_cell_atlas_coords(source_id, Vector2i(0, 1))
		# SOME STRANGE BUG HERE
		var tile_source = tile_set.get_source(source_id)
		#print(tile_source)
		if( tile_source == null ):
			return
		var tile_data = tile_set.get_source(source_id).get_tile_data(Vector2i(0, 1),0)
		if( tile_data == null ):
			return
		# Animal Text output
		var custom_data = tile_data.get_custom_data("type")
		$"../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "ANIMALS: %s" % [custom_data]
		print("There is a %s present here." % [custom_data])
		get_tree().change_scene_to_file("res://src/battle.tscn")dd
	else:
		pass
