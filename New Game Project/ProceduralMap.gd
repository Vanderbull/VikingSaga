extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 8
var height = 8

@onready var player = $CharacterBody2D#get_parent().get_child(1)

func _ready():
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	
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
				set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 0 ,Vector2(3,round((temp+10)/5)))
			else:
				set_cell(0, Vector2i(tile_pos.x - width/2 + x, tile_pos.y - height/2 + y), 0 ,Vector2(round((moist+10)/5),round((temp+10)/5)))
