extends TileMap

# ---------- CONFIG ----------
const LAYER := 0
const SOURCE_ID_TERRAIN := 1 # Change to your tileset's source id
const ATTEMPTS_SPAWN := 200
const SPAWN_RADIUS_TILES := 128

# Moist/Temp are normalized to categories 0..3 (4 bins). Adjust threshold math in _cat().
const BINS := 4

# ---------- NODES ----------
@onready var globals: Node = get_node("/root/Globals")
@onready var game_manager: Node = $"../.."
@onready var player: Node2D = %Player

# Optional HUD labels (guarded when not present)
@onready var hud_ltm: Label = $"../../InGameCanvasLayer/PlayerLocalToMapPosition" if has_node("../../InGameCanvasLayer/PlayerLocalToMapPosition") else null
@onready var hud_gp: Label  = $"../../InGameCanvasLayer/PlayerGlobalPosition"     if has_node("../../InGameCanvasLayer/PlayerGlobalPosition") else null
@onready var hud_p: Label   = $"../../InGameCanvasLayer/PlayerPosition"           if has_node("../../InGameCanvasLayer/PlayerPosition") else null
@onready var hud_hunting: Label = %Hunting if has_node("%Hunting") else null
@onready var animal_map: TileMap = %AnimalMap if has_node("%AnimalMap") else null
@onready var roads_map: TileMap = %TileMap2 if has_node("%TileMap2") else null

# ---------- NOISE ----------
var moisture: FastNoiseLite
var temperature: FastNoiseLite
var altitude: FastNoiseLite

# ---------- STATE ----------
var tile_position_info: Dictionary = {} # Use a dictionary keyed by Vector2i for global indexing
var chunk_size: int = 32
var half_chunk: int = 16
var current_chunk_key: Vector2i = Vector2i(1 << 30, 1 << 30) # sentinel: impossible chunk
var last_center_tile: Vector2i = Vector2i.ZERO

func _ready() -> void:
	# Pull chunk size from Globals if available
	if "chunk_size" in globals:
		chunk_size = int(globals.chunk_size)
	half_chunk = chunk_size / 2

	# Setup noise (deterministic from playerData seeds)
	moisture = FastNoiseLite.new()
	temperature = FastNoiseLite.new()
	altitude = FastNoiseLite.new()

	moisture.seed = int(game_manager.playerData.moisture)
	temperature.seed = int(game_manager.playerData.temperature)
	altitude.seed = int(game_manager.playerData.altitude)

	# Optional: tune frequency for larger or smaller features
	moisture.frequency = 0.015
	temperature.frequency = 0.015
	altitude.frequency = 0.02

	randomize() # RNG for spawning etc.

	# Spawn placement (only once / when requested)
	if globals.ResetPlayerPosition:
		_place_character_non_water()
		globals.ResetPlayerPosition = false

	# First chunk render
	_update_chunk_if_needed(player.position)


func _process(_delta: float) -> void:
	_update_chunk_if_needed(player.position)
	_update_hud()

	# Animal tile lookup (just the tile under the player, no wasted loops)
	if animal_map:
		var tpos := local_to_map(player.position)
		var src_id := animal_map.get_cell_source_id(LAYER, tpos, false)
		if hud_hunting:
			hud_hunting.text = str(src_id)
		globals.Animals = src_id

	# Road placement example (single tile under player)
	if not globals.Hunting and roads_map:
		if game_manager.playerData.Wood > 0 and globals.RoadWorks:
			var pos := local_to_map(player.position)
			roads_map.set_cell(LAYER, pos, SOURCE_ID_TERRAIN, Vector2i(0, 0))
			game_manager.playerData.Wood -= 1
			globals.RoadWorks = not globals.RoadWorks

	# Keep the terrain label for the current tile up to date
	var cur := local_to_map(player.position)
	var mta := _noise_values(cur)
	_apply_biome_side_effects(cur, mta.moist, mta.temp, mta.alt)

# ---------- SPAWNING ----------
func _place_character_non_water() -> void:
	var tries := ATTEMPTS_SPAWN
	while tries > 0:
		tries -= 1
		var rx := randi_range(-SPAWN_RADIUS_TILES, SPAWN_RADIUS_TILES)
		var ry := randi_range(-SPAWN_RADIUS_TILES, SPAWN_RADIUS_TILES)
		var tile_pos := Vector2i(rx, ry)
		var world_pos := map_to_local(tile_pos)

		var mta := _noise_values(tile_pos)
		var mc := _cat(mta.moist)
		var tc := _cat(mta.temp)

		# Water in your scheme: moist==3 && temp<=3  (very/normal water).
		# We'll avoid moist==3 entirely to be safe.
		if not (mc == 3 and tc <= 3):
			player.position = world_pos
			return

	push_error("Failed to find a valid spawn position (non-water).")

# ---------- CHUNKING ----------
func _update_chunk_if_needed(world_pos: Vector2) -> void:
	var center := local_to_map(world_pos)
	last_center_tile = center

	var chunk_key := Vector2i(floor(center.x / float(chunk_size)), floor(center.y / float(chunk_size)))
	if chunk_key == current_chunk_key:
		return # same chunk; nothing to do

	current_chunk_key = chunk_key
	_generate_chunk_around_chunk_key(chunk_key)

func _generate_chunk_around_chunk_key(chunk_key: Vector2i) -> void:
	# Align chunk origin on grid
	var base := Vector2i(chunk_key.x * chunk_size, chunk_key.y * chunk_size)

	# Clear only the area we're about to rewrite for this layer
	# (faster than clear(), avoids nuking other layers if any)
	for x in range(chunk_size):
		for y in range(chunk_size):
			set_cell(LAYER, base + Vector2i(x, y), -1) # empty

	# Fill the chunk with tiles computed from noise
	for x in range(chunk_size):
		for y in range(chunk_size):
			var tile := base + Vector2i(x, y)
			var mta := _noise_values(tile)

			var mc := _cat(mta.moist) # 0..3
			var tc := _cat(mta.temp)  # 0..3

			# Atlas coordinates: (moist_category, temp_category)
			set_cell(LAYER, tile, SOURCE_ID_TERRAIN, Vector2i(mc, tc))

			# Cache info (use dictionary keyed by tile to avoid collisions)
			tile_position_info[tile] = "M:%d, T:%d, Alt:%.2f" % [mc, tc, mta.alt]

# ---------- BIOME / NOISE ----------
# Categorize -10..10 into 0..3 bins. Adjust as needed.
func _cat(v: float) -> int:
	# Maps approximately: [-10,-5] -> 0, (-5,0] -> 1, (0,5] -> 2, (5,10] -> 3
	var c := int(round((v + 10.0) / 5.0))
	return clampi(c, 0, BINS - 1)

# Pack values for convenience
class_name _MTA
class _MTA:
	var moist: float
	var temp: float
	var alt: float

func _noise_values(tile: Vector2i) -> _MTA:
	var m := moisture.get_noise_2d(tile.x, tile.y) * 10.0
	var t := temperature.get_noise_2d(tile.x, tile.y) * 10.0
	var a := altitude.get_noise_2d(tile.x, tile.y) * 10.0
	var o := _MTA.new()
	o.moist = m; o.temp = t; o.alt = a
	return o

# Centralized biome side effects (sets globals + debugging string)
func _apply_biome_side_effects(tile: Vector2i, moist: float, temp: float, alt: float) -> void:
	if globals.Hunting:
		return

	var mc := _cat(moist)
	var tc := _cat(temp)

	var label := ""
	var terrain := ""

	if mc == 1 and tc == 1:
		label = "FOREST"
		terrain = "Forest"
	elif tc == 0:
		label = "SNOW OR DEEP WATER"
		terrain = "Snow"
	elif mc == 0 and tc >= 2:
		label = "DESERT"
		terrain = "Sand"
	elif mc == 1 and tc >= 3:
		label = "DESERT"
		terrain = "Sand"
	elif mc == 2 and tc >= 3:
		label = "LIGHT FOREST"
		terrain = "Forest"
	elif mc == 3 and tc == 3:
		label = "VERY SHALLOW WATER"
		terrain = "Water"
	elif mc == 3 and tc <= 2:
		label = "NORMAL DEPTH WATER"
		terrain = "Water"
	else:
		label = "GRASS"
		terrain = "Grass"

	var info := " %s Moist:%d, Temp:%d, Alt:%.2f" % [label, mc, tc, alt]
	tile_position_info[tile] = info
	globals.Terrain = terrain

	# Original side-effects mirrored; adjust as needed
	match terrain:
		"Forest":
			globals.ForestCutting = false
		"Snow", "Sand", "Water", "Grass":
			globals.ForestCutting = false

# Backwards‑compatible API (kept signature; now returns the terrain string)
func get_terrain_type(tile_pos_x: int, tile_pos_y: int) -> String:
	var tile := Vector2i(tile_pos_x, tile_pos_y)
	var mta := _noise_values(tile)
	_apply_biome_side_effects(tile, mta.moist, mta.temp, mta.alt)
	return String(globals.Terrain)

# ---------- DEBUG / HUD ----------
func _update_hud() -> void:
	if hud_ltm:
		hud_ltm.text = "LocalToMap " + str(local_to_map(player.position))
	if hud_gp:
		hud_gp.text = "GlobalPosition " + str(player.global_position)
	if hud_p:
		hud_p.text = "Position " + str(player.position)
