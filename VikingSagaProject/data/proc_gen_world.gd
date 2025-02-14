extends Node2D
const CHUNK_SIZE: int = 32             # size of each chunk in tiles
const RENDER_DISTANCE: int = 3         # how many chunks outward from player to load
const TILE_SIZE: int = 32              # size of tile in pixels (for coordinate conversion)

var tilemap: TileMap                   # assign via onready or in scene
var generated_chunks = {}             # set of Vector2i chunk coordinates that are loaded

# Utility to get player's current chunk coordinate
func get_player_chunk() -> Vector2i:
    # Assuming you have a reference to the player node
    var player_pos: Vector2 = get_node("Player").global_position
    # Convert player position to tile coordinates, then to chunk coordinates
    var player_tile: Vector2i = tilemap.local_to_map(player_pos)
    return Vector2i(floor(player_tile.x / CHUNK_SIZE), floor(player_tile.y / CHUNK_SIZE))

# Check and load/unload chunks around the player
func update_chunks():
    var current_chunk = get_player_chunk()
    # Load all chunks in the radius that are not yet generated
    for cx in range(current_chunk.x - RENDER_DISTANCE, current_chunk.x + RENDER_DISTANCE + 1):
        for cy in range(current_chunk.y - RENDER_DISTANCE, current_chunk.y + RENDER_DISTANCE + 1):
            var chunk_coord = Vector2i(cx, cy)
            if not generated_chunks.has(chunk_coord):
                generate_chunk(chunk_coord)
                generated_chunks[chunk_coord] = true
    # Unload chunks that are too far from player
    for chunk_coord in generated_chunks.keys():
        if abs(chunk_coord.x - current_chunk.x) > RENDER_DISTANCE or abs(chunk_coord.y - current_chunk.y) > RENDER_DISTANCE:
            remove_chunk(chunk_coord)
            generated_chunks.erase(chunk_coord)
# Noise generators for height, moisture, and temperature
const SEA_LEVEL = 0.2    # noise value threshold for water
var noise_height := FastNoiseLite.new()
var noise_moisture := FastNoiseLite.new()
var noise_temperature := FastNoiseLite.new()

func _ready():
    # Initialize noise parameters (type, seed, frequency, etc.)
    noise_height.noise_type = FastNoiseLite.TYPE_OPEN_SIMPLEX
    noise_height.fractal_type = FastNoiseLite.FRACTAL_FBM
    noise_height.octaves = 5
    noise_height.frequency = 0.005
    noise_height.seed = 12345  # use a fixed seed for world persistence

    noise_moisture.noise_type = FastNoiseLite.TYPE_OPEN_SIMPLEX
    noise_moisture.fractal_type = FastNoiseLite.FRACTAL_FBM
    noise_moisture.octaves = 5
    noise_moisture.frequency = 0.01
    noise_moisture.seed = 54321  # different seed from height&#8203;:contentReference[oaicite:13]{index=13}

    noise_temperature.noise_type = FastNoiseLite.TYPE_OPEN_SIMPLEX
    noise_temperature.fractal_type = FastNoiseLite.FRACTAL_FBM
    noise_temperature.octaves = 5
    noise_temperature.frequency = 0.01
    noise_temperature.seed = 99999  # different seed as well

# Determine biome and set tile at a given map coordinate
func set_tile_for_coordinate(map_x: int, map_y: int) -> void:
    var e = noise_height.get_noise_2d(map_x, map_y)      # elevation noise (-1 to 1 range likely)
    var m = noise_moisture.get_noise_2d(map_x, map_y)    # moisture noise
    var t = noise_temperature.get_noise_2d(map_x, map_y) # temperature noise
    # Normalize noise outputs to 0..1 if needed (assuming noise returns ~[-1,1]):
    e = 0.5 * (e + 1.0)
    m = 0.5 * (m + 1.0)
    t = 0.5 * (t + 1.0)
    # Biome selection based on thresholds:
    var tile_id: int
    if e < SEA_LEVEL:
        tile_id = tileset_water   # water tile
    elif e < SEA_LEVEL + 0.05:
        tile_id = tileset_sand    # beach tile
    else:
        # Land biomes:
        if e > 0.8:
            # Mountainous high altitude
            if t < 0.3: 
                tile_id = tileset_snow   # cold and high -> snow cap
            else:
                tile_id = tileset_mountain_rock  # warm or moderate -> bare rock
        elif t < 0.3:
            # Low temperature (cold region, not high enough to be snow cap)
            if m > 0.5:
                tile_id = tileset_snow   # cold and wet -> snow (or tundra)
            else:
                tile_id = tileset_tundra_grass  # cold and dry -> tundra/grass
        elif m < 0.2:
            tile_id = tileset_desert     # hot/dry -> desert
        elif m > 0.7:
            tile_id = tileset_forest     # wet -> forest (could differentiate jungle vs temperate by t if needed)
        else:
            tile_id = tileset_plains     # default grassland/plains
    # Set the tile in the TileMap (layer 0 assumed for terrain)
    tilemap.set_cell(0, Vector2i(map_x, map_y), 0, Vector2i(tile_id, 0))
func generate_river_from(x, y):
    var current = Vector2i(x, y)
    var max_steps = 200
    while max_steps > 0:
        max_steps -= 1
        # Mark current as river
        tilemap.set_cell(0, current, 0, Vector2i(tileset_water, 0))
        # Find next step: among neighbors, go to the one with lowest height noise (to flow downhill)
        var lowest_neighbor = current
        var lowest_h = noise_height.get_noise_2d(current.x, current.y)
        for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
            var n = current + dir
            var h = noise_height.get_noise_2d(n.x, n.y)
            if h < lowest_h:
                lowest_h = h
                lowest_neighbor = n
        # Add some noise-based twist so river isn't straight line
        var angle_noise = noise_moisture.get_noise_2d(current.x, current.y)
        if angle_noise < -0.5:
            # e.g., bias to turn left or right randomly
            lowest_neighbor = current + Vector2i(dir.y, dir.x)
        current = lowest_neighbor
        if lowest_h < SEA_LEVEL:
            break  # reached water/ocean
# Cloud data structure
class Cloud:
    var position: Vector2
    var velocity: Vector2
    var raining: bool = false
    var storm: bool = false
    var rain_timer: float = 0.0  # to track rain duration or time since last effect

# Configuration
var wind_direction: Vector2 = Vector2(1, 0)    # e.g., blowing east
var wind_speed: float = 20.0                   # pixels per second for clouds
const CLOUD_SPAWN_INTERVAL = 5.0               # spawn a new cloud every 5 seconds (as an example)
var cloud_timer: float = 0.0
var clouds: Array[Cloud] = []

# Called every frame to update cloud simulation
func _process(delta: float) -> void:
    # Move clouds
    for cloud in clouds:
        cloud.position += cloud.velocity * delta
        # Apply shadow: (In practice, could adjust a LightOccluder or CanvasModulate node here)
        apply_cloud_shadow(cloud)
        # Rain logic
        if cloud.raining:
            cloud.rain_timer += delta
            if cloud.rain_timer > 1.0:
                cloud.rain_timer = 0.0
                apply_rain_effect(cloud)
            # Occasional lightning if storm
            if cloud.storm and randi() % 1000 < 5:  # ~0.5% chance each frame
                spawn_lightning(cloud)
        # Remove cloud if far away
        var player_pos = get_node("Player").global_position
        if cloud.position.distance_to(player_pos) > RENDER_DISTANCE * CHUNK_SIZE * TILE_SIZE * 2:
            clouds.erase(cloud)

    # Spawn new clouds periodically
    cloud_timer += delta
    if cloud_timer >= CLOUD_SPAWN_INTERVAL:
        cloud_timer = 0.0
        spawn_new_cloud()

# Example: spawn a cloud at the upwind boundary
func spawn_new_cloud():
    var player_pos = get_node("Player").global_position
    # spawn slightly upwind of player so it travels across the area
    var spawn_offset = Vector2(-RENDER_DISTANCE * CHUNK_SIZE * TILE_SIZE, 0)  # if wind blows east
    var cloud = Cloud.new()
    cloud.position = player_pos + spawn_offset + Vector2(0, randf() * RENDER_DISTANCE * CHUNK_SIZE * TILE_SIZE * 2) 
    cloud.velocity = wind_direction * wind_speed
    # Randomly decide if this is a rain cloud
    if randf() < 0.3:
        cloud.raining = true
        cloud.storm = randf() < 0.5   # half of rain clouds have lightning
    clouds.append(cloud)

func apply_cloud_shadow(cloud: Cloud):
    # This could darken tiles under the cloud, e.g., by modulating a CanvasItem or using a Light2D.
    # Placeholder: do nothing in code, handled by visuals.
    pass

func apply_rain_effect(cloud: Cloud):
    # For each tile under the cloud's area (maybe use cloud's position as center):
    var cloud_tile = tilemap.local_to_map(cloud.position)
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var tile_pos = cloud_tile + Vector2i(dx, dy)
            var tile_id = tilemap.get_cell(0, tile_pos)
            # If tile is dirt/grass and not already water, make it wet (swap tile ID or mark it)
            if tile_id == tileset_plains or tile_id == tileset_desert:
                tilemap.set_cell(0, tile_pos, 0, Vector2i(tileset_wet_ground, 0))
                wet_tiles[tile_pos] = 5.0  # keep track, wet for 5 seconds after rain
            # If tile is lower than neighbors (depression), accumulate water (puddle)
            # This can be a simple check or use height noise:
            var h = noise_height.get_noise_2d(tile_pos.x, tile_pos.y)
            if h < SEA_LEVEL + 0.05 and tile_id != tileset_water:
                tilemap.set_cell(0, tile_pos, 0, Vector2i(tileset_shallow_water, 0))
                wet_tiles[tile_pos] = 5.0

func spawn_lightning(cloud: Cloud):
    # Pick a random tile under the cloud to strike
    var cloud_tile = tilemap.local_to_map(cloud.position)
    var target = cloud_tile + Vector2i(randi() % 5 - 2, randi() % 5 - 2)  # random offset within cloud area
    # Example effect: if target tile is a tree/forest, burn it; if it's a structure, damage it
    var tile_id = tilemap.get_cell(0, target)
    if tile_id == tileset_forest:
        tilemap.set_cell(0, target, 0, Vector2i(tileset_burnt_ground, 0))
        # Schedule it to regrow after some time if desired
    # (Add any other effects like damaging player or NPC if present at target position)
    # We could also flash a light or play a sound here for visual effect.
func generate_chunk(chunk_coord: Vector2i) -> void:
    # This function can be run in a Thread. It computes noise and decides tiles.
    var start_x = chunk_coord.x * CHUNK_SIZE
    var start_y = chunk_coord.y * CHUNK_SIZE
    var tiles_to_set = []  # will collect tile positions and types
    for local_x in range(0, CHUNK_SIZE):
        for local_y in range(0, CHUNK_SIZE):
            var wx = start_x + local_x
            var wy = start_y + local_y
            # determine tile_id via noise (as done in set_tile_for_coordinate)
            var tile_id = determine_tile(wx, wy)  # your biome logic
            tiles_to_set.append({ "pos": Vector2i(wx, wy), "id": tile_id })
    # Defer setting tiles to main thread to avoid thread conflicts
    call_deferred("apply_generated_chunk", tiles_to_set)

func apply_generated_chunk(data):
    # Runs in main thread: apply the tiles calculated in a background thread
    for cell in data:
        var pos = cell.pos
        var id = cell.id
        tilemap.set_cell(0, pos, 0, Vector2i(id, 0))
func remove_chunk(chunk_coord: Vector2i) -> void:
    var start_x = chunk_coord.x * CHUNK_SIZE
    var start_y = chunk_coord.y * CHUNK_SIZE
    for local_x in range(0, CHUNK_SIZE):
        for local_y in range(0, CHUNK_SIZE):
            var wx = start_x + local_x
            var wy = start_y + local_y
            tilemap.set_cell(0, Vector2i(wx, wy), -1)  # -1 or an empty tile to clear
    ```
This frees up those cells. Alternatively, you can use `TileMap.get_used_cells()` or `get_used_cells_by_id` to find all placed cells and remove those beyond a certain distance&#8203;:contentReference[oaicite:24]{index=24}, but iterating the known chunk range is straightforward. By unloading distant chunks, we keep the TileMap's data size in check and improve performance (less to render and iterate over for physics, etc.).

func _draw():
    if DEBUG_CHUNK_BOUNDS:
        var view_rect = get_viewport().get_visible_rect()
        var start_x = int(view_rect.position.x) / (CHUNK_SIZE * TILE_SIZE) - 1
        var end_x = int(view_rect.end.x) / (CHUNK_SIZE * TILE_SIZE) + 1
        var start_y = int(view_rect.position.y) / (CHUNK_SIZE * TILE_SIZE) - 1
        var end_y = int(view_rect.end.y) / (CHUNK_SIZE * TILE_SIZE) + 1
        for chunk_x in range(start_x, end_x):
            for chunk_y in range(start_y, end_y):
                var top_left = tilemap.map_to_local(Vector2i(chunk_x * CHUNK_SIZE, chunk_y * CHUNK_SIZE))
                draw_rect(Rect2(top_left.x, top_left.y, CHUNK_SIZE * TILE_SIZE, CHUNK_SIZE * TILE_SIZE), Color(1,0,0,0.2), false)
