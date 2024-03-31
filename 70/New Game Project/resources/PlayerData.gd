extends Resource
class_name PlayerData

@export var version := 1

const save_file_path := "user://save/"
const save_file_name := "PlayerSave.tres"

@export var player_position = Vector2(0,0)

@export var moisture = 0
@export var temperature = 0
@export var altitude = 0

@export var LoadSaveGame = false

@export var PlayerGold = 100
@export var PlayerHides = 100
@export var PlayerThralls = 100
@export var PlayerFarmers = 100
@export var PlayerWarriors = 100

@export var PlayerWood = 0
@export var PlayerSand = 0
@export var PlayerWater = 0

@export var PlayerShip = false
@export var PlayerShipSpeed = 250.0
@export var PlayerFood = 1500


@export var cloud_position = Vector2(100,100)

@export var RoadWorks = false
@export var ForestCutting = false
@export var xdonkey = 0

func change_playerWood(value: int):
	PlayerWood += value
	return PlayerWood
	
func change_player_position(value: Vector2):
	player_position = value
	return player_position
	
func save(path:String, tile_map:TileMap) -> void:
	# Get the number of layers
	var layers = tile_map.get_layers_count()
	var tile_map_layers = []
	# Resize the array to the number of layers
	tile_map_layers.resize(layers)

	# Get the tile_data from each layer
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
