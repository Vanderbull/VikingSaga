extends Node2D

@onready var globals = get_node("/root/Globals")

@export var noise_height_texture : NoiseTexture2D
@export var cloud_texture : Sprite2D

var noise : Noise

var width : int = 400
var height : int = 400

@onready var tile_map = $TileMap

var source_id = 0
var water_atlas = Vector2i(0,1)
var land_atlas = Vector2i(0,0)

var noise_val_arr = []

func _ready():
	cloud_texture = $Sprite2D
	noise = noise_height_texture.noise
	generate_world()
	
func  _process(delta):
	pass
	#cloud_texture.position = globals.cloud_position
	#cloud_texture.position.normalized()
	#print(globals.cloud_position.x)
	
func generate_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noise_val:float = noise.get_noise_2d(x,y)
			if noise_val >= 0.0:
				#land
				tile_map.set_cell(0,Vector2(x,y),source_id, land_atlas)
				pass
			elif noise_val < 0.0:
				#water
				tile_map.set_cell(0,Vector2(x,y),source_id, water_atlas)
				
	#globals.cloud_position.x += 1
			#print(noise_val)
			#noise_val_arr.append(noise_val)
	#print("heighest", noise_val_arr.max())
	#print("lowest", noise_val_arr.min())
			
			
