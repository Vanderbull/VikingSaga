extends TileMap

@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../.."
@onready var player = $Player

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
#var moisture_clouds = FastNoiseLite.new()
#var temperature_clouds = FastNoiseLite.new()
#var altitude_clouds = FastNoiseLite.new()

#static var clear_delay = 10
var tile_position_info = []
#static var flockmos = 0
var grid_size = Vector2(10, 10)  # Tilemap dimensionsw should be globals.chunk_size right?
var tile_data = []

func place_character():
	randomize()
	var plasket = true
	#for x in range(randi()%1001):
	#	for y in range(randi()%1001):
	#if tile_data[x][y] == 0:  # Check for a valid "floor" tile
	var world_position = map_to_local(Vector2(randi()%101, randi()%101))
	var tile_pos = local_to_map(world_position)
	#world_position += cell_size / 2  # Center on the tile
	player.position = world_position
	print(player.position)
	var moist = moisture.get_noise_2d(tile_pos.x, tile_pos.y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	var _alt = altitude.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	while plasket:
		print("reroll")
		if ( round((moist+10)/5) == 3 and round((temp+10)/5) <= 3 ):
			print("water")
			world_position = map_to_local(Vector2(randi()%101, randi()%101))
			tile_pos = local_to_map(world_position)
			moist = moisture.get_noise_2d(tile_pos.x, tile_pos.y) * 10 # -10 to 10
			temp = temperature.get_noise_2d(tile_pos.x, tile_pos.y) * 10
			_alt = altitude.get_noise_2d(tile_pos.x, tile_pos.y) * 10
			player.position = world_position
		else:
			print("dry land")
			plasket = false
	return  # Exit after placing the character

func _ready():
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
	generate_chunk(player.position)
	$"../../InGameCanvasLayer/PlayerLocalToMapPosition".text = "LocalToMap " + str(local_to_map(player.position))
	$"../../InGameCanvasLayer/PlayerGlobalPosition".text = "GlobalPosition " + str(player.global_position)
	$"../../InGameCanvasLayer/PlayerPosition".text = "Position " + str(player.position)
	#generate_chunk(player.position)
	var tile_pos = local_to_map(player.position)
	var _tile_index = tile_pos.x * globals.chunk_size + tile_pos.y
	var moist = moisture.get_noise_2d(tile_pos.x, tile_pos.y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	var alt = altitude.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	
	var tiles = $"../AnimalMap".get_used_cells(0)
	for cell in tiles:
		var custom_data = $"../AnimalMap".get_cell_source_id ( 0, Vector2i(tile_pos.x, tile_pos.y), false )
		$"../../TileInfoWindow/PanelContainer/VBoxContainer/Hunting".text = str(custom_data)
		globals.Animals = custom_data			
	if( !globals.Hunting ):
		if( game_manager.playerData.PlayerWood > 0 and globals.RoadWorks):
			$"../TileMap2".set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(0,0))
			game_manager.playerData.PlayerWood -= 1
			globals.RoadWorks = not globals.RoadWorks
		if( round((moist+10)/5) == 1 and round((temp+10)/5) == 1 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
		elif( round((temp+10)/5) == 0 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " SNOW OR DEEP WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Snow"
		elif( round((moist+10)/5) == 0 and round((temp+10)/5) >= 2 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Sand"
		elif( round((moist+10)/5) == 1 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Sand"
		elif( round((moist+10)/5) == 2 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " LIGHT FORREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) == 3 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " VERY SHALLOW WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) <= 2 ):
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " NORMAL DEPTH WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
		else:
			tile_position_info[tile_pos.x * globals.chunk_size + tile_pos.y] = " GRASS Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Grass"

func get_terrain_type(tile_pos_x, tile_pos_y):
	var tile_pos = local_to_map(player.position)
	var _tile_index = tile_pos.x * globals.chunk_size + tile_pos.y
	var moist = moisture.get_noise_2d(tile_pos_x, tile_pos_y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos_x, tile_pos_y) * 10
	var alt = altitude.get_noise_2d(tile_pos_x, tile_pos_y) * 10
	
	if( !globals.Hunting ):
		if( game_manager.playerData.PlayerWood > 0 and globals.RoadWorks):
			$"../TileMap2".set_cell(0, Vector2i(tile_pos_x, tile_pos_y), 1 ,Vector2(0,0))
			game_manager.playerData.PlayerWood -= 1
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
