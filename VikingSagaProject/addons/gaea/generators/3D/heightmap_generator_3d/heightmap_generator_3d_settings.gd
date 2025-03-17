class_name HeightmapGenerator3DSettings
extends GeneratorSettings3D

## Settings class for generating 3D heightmap terrain in Godot 4.4 with advanced features

# Tile Information
## Tile placement information from the TileSet
@export var tile: TileInfo

# Noise Configuration
## Noise generator for terrain height variation
@export var noise: FastNoiseLite = FastNoiseLite.new():
    set(value):
        noise = value
        if noise:
            _configure_default_noise()
## Additional noise properties for finer control
@export_group("Noise Settings")
@export var noise_seed: int = 0
@export var noise_frequency: float = 0.01
@export_range(1, 8) var noise_octaves: int = 4
@export_range(0.0, 1.0) var noise_persistence: float = 0.5
@export_range(1.0, 4.0) var noise_lacunarity: float = 2.0
@export var noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_PERLIN
@export var noise_fractal_type: FastNoiseLite.FractalType = FastNoiseLite.FRACTAL_FBM
@export var noise_domain_warp: bool = false
@export_range(0.0, 50.0) var noise_domain_warp_strength: float = 0.0

# World Properties
## Enables infinite world generation (requires ChunkLoader3D)
@export var infinite: bool = false:
    set(value):
        infinite = value
        notify_property_list_changed()
## World dimensions in X and Z axes
@export var world_size: Vector2i = Vector2i(16, 16):
    set(value):
        world_size = value.clamp(Vector2i.ONE, Vector2i(1024, 1024))
        _sync_map_sizes()
## Origin offset for infinite worlds
@export var world_offset: Vector2i = Vector2i.ZERO

# Height Parameters
## Base height level for terrain generation
@export_range(0, 256) var height_offset: int = 128
## Maximum height variation from the offset
@export_range(0, 128) var height_intensity: int = 20
## Minimum allowed height (negative values allow underground)
@export var min_height: int = 0
## Maximum allowed height to prevent overflow
@export_range(0, 1024) var max_height: int = 256
## Adds air layer above generated terrain
@export var air_layer: bool = true
## Height curve for non-linear height distribution
@export var height_curve: Curve

# Falloff Settings
@export_group("Falloff Settings", "falloff_")
## Enables falloff effect for island-like terrain
@export var falloff_enabled: bool = false:
    set(value):
        falloff_enabled = value && !infinite
## Falloff map for creating natural edges
@export var falloff_map: FalloffMap:
    set(value):
        falloff_map = value
        if falloff_map:
            falloff_map.size = world_size
            _update_falloff()
## Falloff strength multiplier
@export_range(0.0, 2.0) var falloff_strength: float = 1.0
## Falloff curve for height transition
@export var falloff_curve: Curve
## Falloff noise overlay for irregularity
@export var falloff_noise: FastNoiseLite

# Biome Settings
@export_group("Biome Settings")
## Enables biome-based height modification
@export var use_biomes: bool = false
## Biome noise for variation
@export var biome_noise: FastNoiseLite
## Biome transition smoothness
@export_range(0.0, 1.0) var biome_blend: float = 0.1
## Moisture map for biome generation
@export var moisture_map: NoiseMap:
    set(value):
        moisture_map = value
        if moisture_map:
            moisture_map.size = world_size
## Temperature map for biome generation
@export var temperature_map: NoiseMap:
    set(value):
        temperature_map = value
        if temperature_map:
            temperature_map.size = world_size
## Array of biome definitions
@export var biomes: Array[BiomeSettings]

# Erosion Settings
@export_group("Erosion Settings")
## Enables erosion simulation
@export var enable_erosion: bool = false
## Number of erosion iterations
@export_range(1, 100) var erosion_iterations: int = 10
## Erosion strength
@export_range(0.0, 1.0) var erosion_strength: float = 0.1
## Erosion type (e.g., hydraulic, thermal)
@export_enum("Hydraulic", "Thermal", "Wind") var erosion_type: int = 0

# River Generation
@export_group("River Settings")
## Enables river generation
@export var generate_rivers: bool = false
## Number of rivers to generate
@export_range(0, 10) var river_count: int = 1
## River width
@export_range(1, 5) var river_width: int = 2
## River depth
@export_range(1, 10) var river_depth: int = 3
## River noise for natural bends
@export var river_noise: FastNoiseLite

# Cave Generation
@export_group("Cave Settings")
## Enables cave generation
@export var generate_caves: bool = false
## Cave noise for generation
@export var cave_noise: FastNoiseLite
## Cave threshold
@export_range(0.0, 1.0) var cave_threshold: float = 0.5
## Cave height range
@export var cave_height_range: Vector2i = Vector2i(10, 50)

# Optimization Settings
@export_group("Optimization")
## Chunk size for generation (used when infinite is true)
@export var chunk_size: Vector2i = Vector2i(16, 16)
## Enable LOD (Level of Detail) generation
@export var use_lod: bool = false
## LOD levels when enabled
@export_range(1, 4) var lod_levels: int = 2
## Enable multi-threading for generation
@export var enable_threading: bool = false
## Number of threads to use
@export_range(1, 16) var thread_count: int = 4
## Enable caching of generated data
@export var enable_caching: bool = false

# Debugging
@export_group("Debugging")
## Visualize noise map in editor
@export var debug_noise_preview: bool = false
## Log generation performance
@export var debug_performance: bool = false

# --- Helper Functions ---

## Configures default noise settings
func _configure_default_noise() -> void:
    if noise:
        noise.seed = noise_seed
        noise.frequency = noise_frequency
        noise.octaves = noise_octaves
        noise.persistence = noise_persistence
        noise.lacunarity = noise_lacunarity
        noise.noise_type = noise_type
        noise.fractal_type = noise_fractal_type
        noise.domain_warp_enabled = noise_domain_warp
        noise.domain_warp_amplitude = noise_domain_warp_strength

## Updates falloff map properties
func _update_falloff() -> void:
    if falloff_map and falloff_enabled and !infinite:
        falloff_map.size = world_size
        if falloff_curve:
            falloff_map.set_curve(falloff_curve)

## Synchronizes all map sizes with world_size
func _sync_map_sizes() -> void:
    if falloff_map:
        falloff_map.size = world_size
    if moisture_map:
        moisture_map.size = world_size
    if temperature_map:
        temperature_map.size = world_size

## Validates property visibility and constraints
func _validate_property(property: Dictionary) -> void:
    match property.name:
        "world_size":
            if infinite:
                property.usage = PROPERTY_USAGE_READ_ONLY
        "falloff_enabled", "falloff_map", "falloff_strength", "falloff_curve", "falloff_noise":
            if infinite:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "chunk_size", "world_offset":
            if !infinite:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "biome_noise", "biome_blend", "moisture_map", "temperature_map", "biomes":
            if !use_biomes:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "lod_levels":
            if !use_lod:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "thread_count":
            if !enable_threading:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "erosion_iterations", "erosion_strength", "erosion_type":
            if !enable_erosion:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "river_count", "river_width", "river_depth", "river_noise":
            if !generate_rivers:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "cave_noise", "cave_threshold", "cave_height_range":
            if !generate_caves:
                property.usage = PROPERTY_USAGE_NO_EDITOR

# --- Core Generation Functions ---

## Generates height at a specific position with advanced features
func get_height_at(x: int, z: int) -> float:
    if !noise:
        return float(height_offset)
    
    var height = height_offset
    var noise_value = noise.get_noise_2d(x + world_offset.x, z + world_offset.y) * height_intensity
    
    # Apply height curve if provided
    if height_curve:
        noise_value = height_curve.sample((noise_value / height_intensity + 1.0) / 2.0) * height_intensity * 2.0 - height_intensity
    
    # Apply falloff if enabled
    if falloff_enabled and falloff_map and !infinite:
        var falloff_value = falloff_map.get_value_at(x, z)
        if falloff_noise:
            falloff_value += falloff_noise.get_noise_2d(x, z) * 0.1
            falloff_value = clamp(falloff_value, 0.0, 1.0)
        noise_value *= (1.0 - falloff_value * falloff_strength)
    
    # Apply biome modification
    if use_biomes and biome_noise and moisture_map and temperature_map:
        var biome = _get_biome_at(x, z)
        if biome:
            height += biome.height_offset
            noise_value *= biome.height_multiplier
    
    height += noise_value
    return clamp(height, min_height, max_height)

## Gets the biome at a specific position based on moisture and temperature
func _get_biome_at(x: int, z: int) -> BiomeSettings:
    if not use_biomes or not moisture_map or not temperature_map or biomes.is_empty():
        return null
    
    var moisture = (moisture_map.get_value_at(x, z) + 1.0) / 2.0
    var temperature = (temperature_map.get_value_at(x, z) + 1.0) / 2.0
    
    var best_biome: BiomeSettings = null
    var best_score: float = -1.0
    
    for biome in biomes:
        var score = _calculate_biome_score(biome, moisture, temperature)
        if score > best_score:
            best_score = score
            best_biome = biome
    
    return best_biome

## Calculates a score for how well a biome matches the given moisture and temperature
func _calculate_biome_score(biome: BiomeSettings, moisture: float, temperature: float) -> float:
    var moisture_diff = abs(biome.ideal_moisture - moisture)
    var temperature_diff = abs(biome.ideal_temperature - temperature)
    var blend_factor = 1.0 - (moisture_diff + temperature_diff) / 2.0
    return lerp(0.0, 1.0, blend_factor * (1.0 - biome_blend))

## Checks if a position is within a cave
func is_cave_at(x: int, y: int, z: int) -> bool:
    if not generate_caves or not cave_noise:
        return false
    var cave_value = cave_noise.get_noise_3d(x + world_offset.x, y, z + world_offset.y)
    return cave_value > cave_threshold and y >= cave_height_range.x and y <= cave_height_range.y

# --- Utility Functions ---

## Generates a preview noise map for debugging
func generate_noise_preview() -> Image:
    if not debug_noise_preview or not noise:
        return null
    var image = Image.create(world_size.x, world_size.y, false, Image.FORMAT_RGB8)
    for x in range(world_size.x):
        for z in range(world_size.y):
            var value = (noise.get_noise_2d(x, z) + 1.0) / 2.0
            image.set_pixel(x, z, Color(value, value, value))
    return image

## Resets all settings to default values
func reset_to_defaults() -> void:
    noise_seed = 0
    noise_frequency = 0.01
    noise_octaves = 4
    noise_persistence = 0.5
    noise_lacunarity = 2.0
    noise_type = FastNoiseLite.TYPE_PERLIN
    noise_fractal_type = FastNoiseLite.FRACTAL_FBM
    noise_domain_warp = false
    noise_domain_warp_strength = 0.0
    infinite = false
    world_size = Vector2i(16, 16)
    height_offset = 128
    height_intensity = 20
    min_height = 0
    max_height = 256
    air_layer = true
    falloff_enabled = false
    falloff_strength = 1.0
    use_biomes = false
    biome_blend = 0.1
    enable_erosion = false
    erosion_iterations = 10
    erosion_strength = 0.1
    generate_rivers = false
    river_count = 1
    river_width = 2
    river_depth = 3
    generate_caves = false
    cave_threshold = 0.5
    cave_height_range = Vector2i(10, 50)
    chunk_size = Vector2i(16, 16)
    use_lod = false
    lod_levels = 2
    enable_threading = false
    thread_count = 4
    enable_caching = false
    debug_noise_preview = false
    debug_performance = false
    _configure_default_noise()
    _sync_map_sizes()

## Initialization
func _init() -> void:
    _configure_default_noise()
    _sync_map_sizes()
