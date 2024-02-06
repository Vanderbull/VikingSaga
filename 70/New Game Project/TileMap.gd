extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 128
var height = 128

@onready var player = $Player

func _ready():
	moisture.seed = -296421265#randi()
	temperature.seed = 1329636442#randi()
	altitude.seed = 1469612428#randi()
	print_debug(moisture.seed)
	print_debug(temperature.seed)
	print_debug(altitude.seed)
	
func _process(delta):
	generate_chunk(player.position)
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
