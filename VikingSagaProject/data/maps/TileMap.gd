extends TileMap

@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../.."
@onready var player = $Player

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
var tile_position_info = []
var grid_size = Vector2(10, 10)  # Tilemap dimensionsw should be globals.chunk_size right?
var tile_data = []

func _ready():
	randomize_player_position()
	tile_position_info.resize(256*256)
	tile_position_info.fill("0")
	generate_tilemap()
	if globals.ResetPlayerPosition:
		place_character()
		globals.ResetPlayerPosition = false
	randomize()
	moisture.seed = game_manager.playerData.moisture
	temperature.seed = game_manager.playerData.temperature
	altitude.seed = game_manager.playerData.altitude
	
func randomize_player_position():
	randomize()

func get_random_tile():
	var world_pos = map_to_local(Vector2(randi() % 101, randi() % 101))
	var tile_pos = local_to_map(world_pos)
	return [world_pos, tile_pos]

func get_noise_values(tile_pos):
	var moist = moisture.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	var temp = temperature.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	var alt = altitude.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	return [moist, temp, alt]

# Function to find a tile thats not water to place the character on when spawning
func place_character():
	var attempts = 100  # Limit attempts to avoid infinite loop
	var world_position = Vector2()

	for i in range(attempts):
		var result = get_random_tile()
		world_position = result[0]
		var tile_pos = result[1]
		var noise = get_noise_values(tile_pos)
		var moist = noise[0]
		var temp = noise[1]

		if not (round((moist + 10) / 5) == 3 and round((temp + 10) / 5) <= 3):
			#player.position = world_position
			%Player.position = world_position
			return

	push_error("Failed to find a valid spawn position")

func generate_tilemap():
	var _tile_pos = local_to_map(player.position)
	tile_data.clear()
	for x in range(grid_size.x):
		tile_data.append([])
		for y in range(grid_size.y):
			# Example: Randomly set some tiles as walls (1) or floor (0)
			var tile = (randf() < 0.8) and true or false  # 80% floor, 20% walls
			tile_data[x].append(tile)
			tile_data[x].append(false)
			if tile == true:  # Floor
				#$"../TileMap2".set_cell(0, Vector2i(x, y), 1 ,Vector2(3,0))
				pass
				#set_cell(x, y, 0)  # Use your floor tile ID here
			elif tile == false:  # Wall
				#$"../TileMap2".set_cell(0, Vector2i(x, y), 1 ,Vector2(0,0))
				pass
				#set_cell(x, y, 1)  # Use your wall tile ID here
	#tile_data.resize(256*256)
	#tile_data.fill("0")
	pass
	
func _process(_delta):
	#generate_chunk(player.position)
	generate_chunk(%Player.position)
#	$"../../InGameCanvasLayer/PlayerLocalToMapPosition".text = "LocalToMap " + str(local_to_map(player.position))
#	$"../../InGameCanvasLayer/PlayerGlobalPosition".text = "GlobalPosition " + str(player.global_position)
#	$"../../InGameCanvasLayer/PlayerPosition".text = "Position " + str(player.position)
	$"../../InGameCanvasLayer/PlayerLocalToMapPosition".text = "LocalToMap " + str(local_to_map(%Player.position))
	$"../../InGameCanvasLayer/PlayerGlobalPosition".text = "GlobalPosition " + str(%Player.global_position)
	$"../../InGameCanvasLayer/PlayerPosition".text = "Position " + str(%Player.position)

	var tile_pos = local_to_map(player.position)
	var _tile_index = tile_pos.x * globals.chunk_size + tile_pos.y
	var moist = moisture.get_noise_2d(tile_pos.x, tile_pos.y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	var alt = altitude.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	
	var tiles = %AnimalMap.get_used_cells(0) #$"../AnimalMap".get_used_cells(0)
	for cell in tiles:
		var custom_data = %AnimalMap.get_cell_source_id( 0, Vector2i(tile_pos.x, tile_pos.y), false ) #$"../AnimalMap".get_cell_source_id ( 0, Vector2i(tile_pos.x, tile_pos.y), false )
		%Hunting.text = str(custom_data)
		globals.Animals = custom_data			
	if( !globals.Hunting ):
		if( game_manager.playerData.Wood > 0 and globals.RoadWorks):
			%TileMap2.set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(0,0)) #$"../TileMap2".set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(0,0))
			game_manager.playerData.Wood -= 1
			globals.RoadWorks = not globals.RoadWorks
		if( round((moist+10)/5) == 1 and round((temp+10)/5) == 1 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
			var my_tile_type = globals.TerrainType.FOREST
			#print(globals.TerrainType.keys()[my_tile_type])  # Outputs "FOREST"
		elif( round((temp+10)/5) == 0 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " SNOW OR DEEP WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Snow"
			var my_tile_type = globals.TerrainType.SNOW
			#print(globals.TerrainType.keys()[my_tile_type])
		elif( round((moist+10)/5) == 0 and round((temp+10)/5) >= 2 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Sand"
			var my_tile_type = globals.TerrainType.SAND
			#print(globals.TerrainType.keys()[my_tile_type])
		elif( round((moist+10)/5) == 1 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Sand"
			var my_tile_type = globals.TerrainType.SAND
			#print(globals.TerrainType.keys()[my_tile_type])
		elif( round((moist+10)/5) == 2 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " LIGHT FORREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
			var my_tile_type = globals.TerrainType.FOREST
			#print(globals.TerrainType.keys()[my_tile_type])
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) == 3 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " VERY SHALLOW WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			var my_tile_type = globals.TerrainType.WATER
			#print(globals.TerrainType.keys()[my_tile_type])
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) <= 2 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " NORMAL DEPTH WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			var my_tile_type = globals.TerrainType.WATER
			#print(globals.TerrainType.keys()[my_tile_type])
		else:
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " GRASS Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Grass"
			var my_tile_type = globals.TerrainType.GRASS
			#print(globals.TerrainType.keys()[my_tile_type])

func get_terrain_type(tile_pos_x, tile_pos_y):
	var tile_pos = local_to_map(player.position)
	var _tile_index = tile_pos.x * globals.chunk_size + tile_pos.y
	var moist = moisture.get_noise_2d(tile_pos_x, tile_pos_y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos_x, tile_pos_y) * 10
	var alt = altitude.get_noise_2d(tile_pos_x, tile_pos_y) * 10
	
	if( !globals.Hunting ):
		if( game_manager.playerData.Wood > 0 and globals.RoadWorks):
			%TileMap2.set_cell(0, Vector2i(tile_pos_x, tile_pos_y), 1 ,Vector2(0,0)) #$"../TileMap2".set_cell(0, Vector2i(tile_pos_x, tile_pos_y), 1 ,Vector2(0,0))
			game_manager.playerData.Wood -= 1
			globals.RoadWorks = not globals.RoadWorks
		if( round((moist+10)/5) == 1 and round((temp+10)/5) == 1 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
		elif( round((moist+10)/5) == 2 and round((temp+10)/5) == 1 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
		elif( round((temp+10)/5) == 0 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " SNOW OR DEEP WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Snow"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 0 and round((temp+10)/5) >= 2 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Sand"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 1 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Sand"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 2 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " LIGHT FORREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) == 3 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " VERY SHALLOW WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) <= 2 ):
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " NORMAL DEPTH WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			globals.ForestCutting = false
		else:
			tile_position_info[tile_pos_x * globals.chunk_size + tile_pos_y] = " GRASS Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Grass"
			globals.ForestCutting = false
			return globals.Terrain
	
func generate_chunk(p_position):
	var tile_pos = local_to_map(p_position)
	for x in range(globals.chunk_size):
		for y in range(globals.chunk_size):
			var moist = moisture.get_noise_2d(tile_pos.x - globals.chunk_size/2.0 + x, tile_pos.y - globals.chunk_size/2.0 + y) * 10.0 # -10 to 10
			var temp = temperature.get_noise_2d(tile_pos.x - globals.chunk_size/2.0 + x, tile_pos.y - globals.chunk_size/2.0 + y) * 10.0
			var _alt = altitude.get_noise_2d(tile_pos.x - globals.chunk_size/2.0 + x, tile_pos.y - globals.chunk_size/2.0 + y) * 10.0
			set_cell(0, Vector2i(tile_pos.x - globals.chunk_size/2.0 + x, tile_pos.y - globals.chunk_size/2.0 + y), 1.0 ,Vector2(round((moist+10.0)/5.0),round((temp+10.0)/5.0)))
