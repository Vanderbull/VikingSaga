extends TileMap

@onready var globals = get_node("/root/Globals")
@onready var game_manager = $"../.."

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var moisture_clouds = FastNoiseLite.new()
var temperature_clouds = FastNoiseLite.new()
var altitude_clouds = FastNoiseLite.new()

var width = 16
var height = 16

@onready var player = $Player
static var clear_delay = 10

var tile_position_info = []
static var flockmos = 0

func _ready():
	randomize()
	tile_position_info.resize(256*256)
	tile_position_info.fill("0")
	moisture.seed = game_manager.playerData.moisture
	temperature.seed = game_manager.playerData.temperature
	altitude.seed = game_manager.playerData.altitude

func _process(_delta):
	$"../../InGameCanvasLayer/PlayerLocalToMapPosition".text = "LocalToMap " + str(local_to_map(player.position))
	$"../../InGameCanvasLayer/PlayerGlobalPosition".text = "GlobalPosition " + str(player.global_position)
	$"../../InGameCanvasLayer/PlayerPosition".text = "Position " + str(player.position)
	generate_chunk(player.position)
	
	var tile_pos = local_to_map(player.position)
	var tile_index = tile_pos.x * width + tile_pos.y
	
	var moist = moisture.get_noise_2d(tile_pos.x, tile_pos.y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	var alt = altitude.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	
	var tiles = $"../AnimalMap".get_used_cells(0)
	for cell in tiles:
		var custom_data = $"../AnimalMap".get_cell_source_id ( 0, Vector2i(tile_pos.x, tile_pos.y), false )
		$"../../TileInfoWindow/PanelContainer/VBoxContainer/Hunting".text = str(custom_data)
		globals.Animals = custom_data
		#print(custom_data)
		#if( custom_data == 1):
			#globals.Animals = "Wolf"
			#$"../../TileInfoWindow/PanelContainer/VBoxContainer/Hunting".text = str(globals.Hunting)
		#else:
			#$"../../TileInfoWindow/PanelContainer/VBoxContainer/Hunting".text = str(globals.Hunting)
			#globals.Animals = "None"
			
	if( !globals.Hunting ):
		if( game_manager.playerData.PlayerWood > 0 and globals.RoadWorks):
			$"../TileMap2".set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(0,0))
			game_manager.playerData.PlayerWood -= 1
			globals.RoadWorks = not globals.RoadWorks

		if( round((moist+10)/5) == 1 and round((temp+10)/5) == 1 ):
			tile_position_info[tile_pos.x * width + tile_pos.y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
			#if(globals.ForestCutting):
				#game_manager.playerData.PlayerWood += 1
		elif( round((temp+10)/5) == 0 ):
			tile_position_info[tile_pos.x * width + tile_pos.y] = " SNOW OR DEEP WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Snow"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 0 and round((temp+10)/5) >= 2 ):
			tile_position_info[tile_pos.x * width + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			#if(globals.ForestCutting):
				#globals.PlayerSand+=1
			globals.Terrain = "Sand"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 1 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos.x * width + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			#if(globals.ForestCutting):
				#globals.PlayerSand+=1
			globals.Terrain = "Sand"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 2 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos.x * width + tile_pos.y] = " LIGHT FORREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) == 3 ):
			tile_position_info[tile_pos.x * width + tile_pos.y] = " VERY SHALLOW WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) <= 2 ):
			tile_position_info[tile_pos.x * width + tile_pos.y] = " NORMAL DEPTH WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			globals.ForestCutting = false
		else:
			tile_position_info[tile_pos.x * width + tile_pos.y] = " GRASS Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Grass"
			globals.ForestCutting = false
			#if(globals.CollectClay):
				#game_manager.playerData.PlayerClay += 1

func get_terrain_type(tile_pos_x, tile_pos_y):
	
	var tile_pos = local_to_map(player.position)
	var tile_index = tile_pos.x * width + tile_pos.y
	
	var moist = moisture.get_noise_2d(tile_pos_x, tile_pos_y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos_x, tile_pos_y) * 10
	var alt = altitude.get_noise_2d(tile_pos_x, tile_pos_y) * 10
	
	if( !globals.Hunting ):
		if( game_manager.playerData.PlayerWood > 0 and globals.RoadWorks):
			$"../TileMap2".set_cell(0, Vector2i(tile_pos_x, tile_pos_y), 1 ,Vector2(0,0))
			game_manager.playerData.PlayerWood -= 1
			globals.RoadWorks = not globals.RoadWorks
		if( round((moist+10)/5) == 1 and round((temp+10)/5) == 1 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
		elif( round((moist+10)/5) == 2 and round((temp+10)/5) == 1 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
		elif( round((temp+10)/5) == 0 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " SNOW OR DEEP WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Snow"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 0 and round((temp+10)/5) >= 2 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			if(globals.ForestCutting):
				globals.PlayerSand+=1
			globals.Terrain = "Sand"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 1 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			if(globals.ForestCutting):
				globals.PlayerSand+=1
			globals.Terrain = "Sand"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 2 and round((temp+10)/5) >= 3 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " LIGHT FORREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Forest"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) == 3 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " VERY SHALLOW WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			globals.ForestCutting = false
		elif( round((moist+10)/5) == 3 and round((temp+10)/5) <= 2 ):
			tile_position_info[tile_pos_x * width + tile_pos_y] = " NORMAL DEPTH WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Water"
			globals.ForestCutting = false
		else:
			tile_position_info[tile_pos_x * width + tile_pos_y] = " GRASS Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			globals.Terrain = "Grass"
			globals.ForestCutting = false
			return globals.Terrain
	
	pass
	
func generate_chunk(position):
	var tile_pos = local_to_map(position)
	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10 # -10 to 10
			var temp = temperature.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			var alt = altitude.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			
			set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
