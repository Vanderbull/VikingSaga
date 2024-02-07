extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var moisture_tree = FastNoiseLite.new()
var temperature_tree = FastNoiseLite.new()
var altitude_tree = FastNoiseLite.new()

var width = 256
var height = 256

@onready var player = $Player
static var clear_delay = 10

func _ready():
	moisture.seed = -296421265#randi()
	temperature.seed = 1329636442#randi()
	altitude.seed = 1469612428#randi()

	moisture_tree.seed = randi()
	temperature_tree.seed = randi()
	altitude_tree.seed = randi()

	
func _process(delta):
	generate_chunk(player.position)
	if clear_delay == 0:
		clear_layer(1)
		clear_delay = 10
		moisture_tree.seed = randi()
		temperature_tree.seed = randi()
		altitude_tree.seed = randi()
	else:
		clear_delay -= 1

	#print("Position: " + str(player.position.x) + " , " + str(player.position.y))
	
func generate_chunk(position):
	var tile_pos = local_to_map(position)
	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10 # -10 to 10
			var temp = temperature.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			var alt = altitude.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			#set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 0 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
			
			if alt  < 2:
				set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(3,round((temp+10)/5)))
			else:
				set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
				
				#set_cell(0, Vector2i(tile_pos.x + 4, tile_pos.y), 0 ,Vector2(25,14))
				
	for x in range(width):
		for y in range(height):
			var moist_tree = moisture_tree.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10 # -10 to 10
			var temp_tree = temperature_tree.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			var alt_tree = altitude_tree.get_noise_2d(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y) * 10
			#set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 0 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
			
			if alt_tree  > 2:
				set_cell(1, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(0,0))
			#else:
				#set_cell(1, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 1 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
				
				#set_cell(1, Vector2i(tile_pos.x + 4, tile_pos.y), 0 ,Vector2(25,14))
