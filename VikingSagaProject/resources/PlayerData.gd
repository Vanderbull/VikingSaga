extends Resource
class_name PlayerData

@export var version := 1

const save_file_path := "user://save/"
const save_file_name := "PlayerSave.tres"

@export var position = Vector2(0,0)
@export var moisture = 0
@export var temperature = 0
@export var altitude = 0
@export var LoadSaveGame = false
# Resources
@export var Wood = 0
@export var Sand = 0
@export var Clay = 0
@export var Coal = 0
@export var Water = 10000
@export var Food = 10000
@export var Gold = 0
@export var Silver = 0
@export var Iron = 0
@export var Copper = 0
@export var Meat = 0
@export var Fish = 0
# Actions
@export var RoadWorks = false
@export var ForestCutting = false
@export var DigSand = false
@export var CollectWater = false
@export var CollectClay = false
@export var DigClay = false
@export var Hunting = false

func change_player_position(value: Vector2):
	position = value
	return position
	
func save(path:String, tile_map:TileMap) -> void:
	# Get the number of layers
	var layers = tile_map.get_layers_count()
	var tile_map_layers = []
	# Resize the array to the number of layers
	tile_map_layers.resize(layers)

	# Get the tile_data from each layera
	for layer in layers:
		tile_map_layers[layer] = tile_map.get("layer_%s/tile_data" % layer)

	# Save the array to a file as a JSON
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(tile_map_layers))
	file.close()	

func load(path:String, tile_map:TileMap) -> void:
	# Read the file as a String and parse the JSON
	var layer_data = JSON.parse_string(FileAccess.get_file_as_string(path))
	# For each entry in the array, set the tilemap layer tile_data
	for layer in layer_data.size():
		var tiles = layer_data[layer]
		tile_map.set('layer_%s/tile_data' % layer, tiles)
