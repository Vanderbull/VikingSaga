extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var moisture_clouds = FastNoiseLite.new()
var temperature_clouds = FastNoiseLite.new()
var altitude_clouds = FastNoiseLite.new()

var width = 3
var height = 3

@onready var player = $Player
static var clear_delay = 10

var tile_position_info = []

func _ready():
	#position = Vector2i(0,0)
	#player.global_position = Vector2i(0,0)
	#player.position = Vector2(0.0,0.0)

	tile_position_info.resize(256*256)
	tile_position_info.fill("0")
	#Randomize world
	moisture.seed = -296421265#randi()
	temperature.seed = 1329636442#randi()
	altitude.seed = 1469612428#randi()

	#Randomize cloud layer
	moisture_clouds.seed = randi()
	temperature_clouds.seed = randi()
	altitude_clouds.seed = randi()

static var flockmos = 0

func _process(_delta):
	$"../../InGameCanvasLayer/PlayerLocalToMapPosition".text = "LocalToMap " + str(local_to_map(player.position))
	$"../../InGameCanvasLayer/PlayerGlobalPosition".text = "GlobalPosition " + str(player.global_position)
	$"../../InGameCanvasLayer/PlayerPosition".text = "Position " + str(player.position)

	generate_chunk(player.position)
	
	var tile_pos = local_to_map(player.position)
	var tile_index = tile_pos.x * width + tile_pos.y
	print(tile_pos)
	print(tile_position_info[tile_index])
	#if clear_delay == 0:
		#clear_layer(1)
		#clear_delay = 10
		#moisture_tree.seed = randi()
		#temperature_tree.seed = randi()
		#altitude_tree.seed = randi()
	#else:
		#clear_delay -= 1

	#print("Position: " + str(player.position.x) + " , " + str(player.position.y))
	
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
			if alt  < 2:
				set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(3,round((temp+10)/5)))
				tile_position_info[tile_pos.x * width + tile_pos.y] = " WATER Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			else:
				set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
				if( round((moist+10)/5) >= 1 and round((temp+10)/5) == 1 ):
					tile_position_info[tile_pos.x * width + tile_pos.y] = " FORERST Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
				else:
					tile_position_info[tile_pos.x * width + tile_pos.y] = " GRASS Moist: " + str(round((moist+10)/5)) + ", Temp: " + str(round((temp+10)/5)) + ", Alt: " + str(alt)
			
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
