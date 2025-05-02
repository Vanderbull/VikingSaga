extends TileMap
@onready var globals = get_node("/root/Globals")
@onready var player = $"../TileMap/Player"
# Function to check if a tile is set at a specific grid position
func is_tile_set(x: int, y: int) -> bool:
	var cell_source_id = get_cell_source_id(0,Vector2i(x, y))
	#print (cell_source_id)
	return cell_source_id != -1

func get_tile_info(tilemap: TileMap, cell_position: Vector2i):
	#print("CELL X %i",cell_position.x)
	#print("CELL Y %i",cell_position.y)
	# Get the TileSet resource from the TileMap
	var tileset = tilemap.tile_set
	if not tileset:
		return null  # TileSet is not assigned
	# Get the tile ID at the specified cell position
	var tile_id = get_cell_source_id(0,Vector2i(cell_position.x, cell_position.y))#tilemap.get_cell(cell_position)
	if tile_id == -1:
		return null
	# Fetch the tile information from the TileSet
	var tile_data = tileset.get_source(tile_id)
	if tile_data is TileSetAtlasSource:
		print("ATLAS ATLAS WOOOHOOOO WOOOO")
		var atlas_coordinates = tilemap.get_cell_atlas_coords(tile_id, cell_position)
		# For atlas tiles
		var texture_region = tile_data.get_tile_texture_region(cell_position, tile_id)
		#var collision_shapes = tile_data.get_tile_shapes(tile_id)
		#var metadata = tileset.tile_get_metadata(tile_id)
		return {
			"type": "atlas_tile",
			"texture_region": texture_region,
			"atlass_region": atlas_coordinates,
			#"collision_shapes": collision_shapes,
			#"metadata": metadata
		}		
	#tileset.get_tile_data(tile_id)
	#return tile_data
	
func _ready():
	print("ncp _ready...")

func _process(_delta):
	var tile_pos = $".".local_to_map(player.position)
	var datan
	datan = get_tile_info($".",tile_pos)
	if datan != null:
		print(datan)
	#print(tile_pos)
	#print_debug("processing animal map...")
	#if is_tile_set(globals.player_position.x,globals.player_position.y):
	if is_tile_set(tile_pos.x,tile_pos.y):
		var source_id = get_cell_source_id(0,Vector2i(tile_pos.x, tile_pos.y))
		if( source_id == null ):
			#print_debug("source_id is null")
			return
		else:
			return
			#print_debug(source_id)
		var _atlas_coord := get_cell_atlas_coords(source_id, Vector2i(0, 1))
		# SOME STRANGE BUG HERE
		var tile_source = tile_set.get_source(source_id)
		#print(tile_source)
		if( tile_source == null ):
			#print_debug("tile_source is null")
			return
		var tile_data = tile_set.get_source(source_id).get_tile_data(Vector2i(0, 1),0)
		if( tile_data == null ):
			#print_debug("tile_data is null")
			return
		# Animal Text output
		var custom_data = tile_data.get_custom_data("type")
		$"../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals".text = "NPC: %s" % [custom_data]
		#print("There is a %s present here." % [custom_data])
	else:
		return
