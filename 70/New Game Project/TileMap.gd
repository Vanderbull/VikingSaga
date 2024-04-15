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
	#position = Vector2i(0,0)
	#player.global_position = Vector2i(0,0)
	#player.position = Vector2(0.0,0.0)

	tile_position_info.resize(256*256)
	tile_position_info.fill("0")

	#if( !game_manager.playerData.LoadSaveGame ):
		#print("Not loading save game...")
		#moisture.seed = randi()
		#temperature.seed = randi()
		#altitude.seed = randi()
		#game_manager.playerData.LoadSaveGame = !game_manager.playerData.LoadSaveGame
	#else:
	#print("Loading save game...")
	moisture.seed = game_manager.playerData.moisture
	temperature.seed = game_manager.playerData.temperature
	altitude.seed = game_manager.playerData.altitude

func _process(_delta):
	$"../../InGameCanvasLayer/PlayerLocalToMapPosition".text = "LocalToMap " + str(local_to_map(player.position))
	$"../../InGameCanvasLayer/PlayerGlobalPosition".text = "GlobalPosition " + str(player.global_position)
	$"../../InGameCanvasLayer/PlayerPosition".text = "Position " + str(player.position)
	#$"../../InGameCanvasLayer/Trees".text = "Trees " + str(globals.PlayerWood)
	#$"../../InGameCanvasLayer/Sand".text = "Sand: " + str(globals.PlayerSand)
	generate_chunk(player.position)
	
	var tile_pos = local_to_map(player.position)
	var tile_index = tile_pos.x * width + tile_pos.y
	
	var moist = moisture.get_noise_2d(tile_pos.x, tile_pos.y) * 10 # -10 to 10
	var temp = temperature.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	var alt = altitude.get_noise_2d(tile_pos.x, tile_pos.y) * 10
	
	var data = $"../AnimalMap".get_cell_tile_data ( 0, Vector2i(tile_pos.x, tile_pos.y) )
	if data:
		globals.Hunt = true
		print(data.get_custom_data("Type"))
	else:
		globals.Hunt = false
		print("No animal present")
	
	#if( globals.PlayerWood > 0 and globals.RoadWorks):
	if( game_manager.playerData.PlayerWood > 0 and globals.RoadWorks):
		$"../TileMap2".set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(0,0))
		game_manager.playerData.PlayerWood -= 1
		globals.RoadWorks = not globals.RoadWorks
	#set_cell(0, Vector2i(tile_pos.x, tile_pos.y), 1 ,Vector2(0,0))

	if( round((moist+10)/5) == 1 and round((temp+10)/5) == 1 ):
		tile_position_info[tile_pos.x * width + tile_pos.y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
		globals.Terrain = "Forest"
		#if(globals.ForestCutting):
		#	game_manager.playerData.PlayerWood += 1
			#globals.PlayerWood+=1
	elif( round((moist+10)/5) == 2 and round((temp+10)/5) == 1 ):
		tile_position_info[tile_pos.x * width + tile_pos.y] = " FOREST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
		globals.Terrain = "Forest"
		#if(globals.ForestCutting):
		#	game_manager.playerData.PlayerWood += 1
			#globals.PlayerWood+=1
	#elif( round((moist+10)/5) >= 3 ):
		#tile_position_info[tile_pos.x * width + tile_pos.y] = " WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
	elif( round((temp+10)/5) == 0 ):
		tile_position_info[tile_pos.x * width + tile_pos.y] = " SNOW OR DEEP WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
		globals.Terrain = "Snow"
		globals.ForestCutting = false
	elif( round((moist+10)/5) == 0 and round((temp+10)/5) >= 2 ):
		tile_position_info[tile_pos.x * width + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
		if(globals.ForestCutting):
			globals.PlayerSand+=1
		globals.Terrain = "Sand"
		globals.ForestCutting = false
	elif( round((moist+10)/5) == 1 and round((temp+10)/5) >= 3 ):
		tile_position_info[tile_pos.x * width + tile_pos.y] = " DESERT Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
		if(globals.ForestCutting):
			globals.PlayerSand+=1
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
		globals.Terrain = "Clay"
		globals.ForestCutting = false
	
func generate_chunk(position):
	var tile_pos = local_to_map(position)
	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10 # -10 to 10
			var temp = temperature.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			var alt = altitude.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			
			
			#set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 0 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
			
			#set_cell(0, Vector2i(tile_pos.x - width/2 + x - 0.5, tile_pos.y - height/2 + y - 0.5), 1 ,Vector2(3,round((temp+10)/5)))
			
			#set_cell(0, Vector2i(0, 0), 1 ,Vector2(3,round((temp+10)/5)))
			
			# IF MOIST 1 or 2 and temp 1
			# if moist 3 and temp anything then water
			#if alt  < 2:
				#set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(3,round((temp+10)/5)))
				#tile_position_info[tile_pos.x * width + tile_pos.y] = " WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			#else:
			#if( round((moist+10)/5) == 0 ):
				#print(" Extremly dry")
			#if( round((moist+10)/5) == 1 ):
				#print(" very dry")
			#if( round((moist+10)/5) == 2 ):
				#print(" normal dry")
			#if( round((moist+10)/5) == 3 ):
				#print(" wet dry")
				#
			#if( round((temp+10)/5) == 0 ):
				#print(" Extremly cold")
			#if( round((temp+10)/5) == 1 ):
				#print(" very cold")
			#if( round((temp+10)/5) == 2 ):
				#print(" normal cold")
			#if( round((temp+10)/5) == 3 ):
				#print(" not cold")
			
			set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
			#if( round((moist+10)/5) >= 1 and round((temp+10)/5) == 1 ):
				#tile_position_info[tile_pos.x * width + tile_pos.y] = " FORERST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			#elif( round((moist+10)/5) >= 2 and round((temp+10)/5) == 1 ):
				#tile_position_info[tile_pos.x * width + tile_pos.y] = " FORERST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			#elif( round((moist+10)/5) >= 3 ):
				#tile_position_info[tile_pos.x * width + tile_pos.y] = " WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			#else:
				#tile_position_info[tile_pos.x * width + tile_pos.y] = " GRASS Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			
			#if( moist > 0 and moist < 3):
				#tile_position_info[x * width + y] = " FORREST Moist: " + str(moist) + ", Temp: " + str(temp) + ", Alt: " + str(alt)
			#else:
				#tile_position_info[x * width + y] = "Moist: " + str(moist) + ", Temp: " + str(temp) + ", Alt: " + str(alt)
				
				#set_cell(0, Vector2i(tile_pos.x + 4, tile_pos.y), 0 ,Vector2(25,14))
	
	#for x in range(width):
		#for y in range(height):
			#var moist_clouds = moisture_clouds.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10 # -10 to 10
			#var temp_clouds = temperature_clouds.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			#var alt_clouds = altitude_clouds.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			##set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 0 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
			#
			#if alt_clouds  > 2:
				##delete first tiles then add the new tiles one pixel offset
				#set_cell(1, Vector2i(tile_pos.x - width/2 + x+ flockmos, tile_pos.y - height/2 + y), 1 ,Vector2(0,0))
			#else:
				#set_cell(1, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
				
				#set_cell(1, Vector2i(tile_pos.x + 4, tile_pos.y), 0 ,Vector2(25,14))
