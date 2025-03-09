class_name HeightmapGenerator3DSettings
extends GeneratorSettings3D

## Settings class for generating 3D heightmap terrain in Godot 4.4

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
        if falloff_map:
            falloff_map.size = world_size

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

# Biome Settings
@export_group("Biome Settings")
## Enables biome-based height modification
@export var use_biomes: bool = false
## Biome noise for variation
@export var biome_noise: FastNoiseLite
## Biome transition smoothness
@export_range(0.0, 1.0) var biome_blend: float = 0.1

# Optimization Settings
@export_group("Optimization")
## Chunk size for generation (used when infinite is true)
@export var chunk_size: Vector2i = Vector2i(16, 16)
## Enable LOD (Level of Detail) generation
@export var use_lod: bool = false
## LOD levels when enabled
@export_range(1, 4) var lod_levels: int = 2

## Configures default noise settings
func _configure_default_noise() -> void:
    if noise:
        noise.seed = noise_seed
        noise.frequency = noise_frequency
        noise.octaves = noise_octaves
        noise.persistence = noise_persistence
        noise.lacunarity = noise_lacunarity
        noise.noise_type = FastNoiseLite.TYPE_PERLIN

## Updates falloff map properties
func _update_falloff() -> void:
    if falloff_map and falloff_enabled and !infinite:
        falloff_map.size = world_size
        if falloff_curve:
            falloff_map.set_curve(falloff_curve)

## Validates property visibility and constraints
func _validate_property(property: Dictionary) -> void:
    match property.name:
        "world_size":
            if infinite:
                property.usage = PROPERTY_USAGE_READ_ONLY
        "falloff_enabled", "falloff_map", "falloff_strength", "falloff_curve":
            if infinite:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "chunk_size":
            if !infinite:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "biome_noise", "biome_blend":
            if !use_biomes:
                property.usage = PROPERTY_USAGE_NO_EDITOR
        "lod_levels":
            if !use_lod:
                property.usage = PROPERTY_USAGE_NO_EDITOR

## Generates height at a specific position
func get_height_at(x: int, z: int) -> float:
    if !noise:
        return float(height_offset)
    
    var height = height_offset
    var noise_value = noise.get_noise_2d(x, z) * height_intensity
    
    # Apply falloff if enabled
    if falloff_enabled and falloff_map and !infinite:
        var falloff_value = falloff_map.get_value_at(x, z)
        noise_value *= (1.0 - falloff_value * falloff_strength)
    
    # Apply biome modification
    if use_biomes and biome_noise:
        var biome_factor = biome_noise.get_noise_2d(x, z)
        height += biome_factor * height_intensity * biome_blend
    
    height += noise_value
    return clamp(height, min_height, max_height)

## Initialization
func _init() -> void:
    _configure_default_noise()
    if falloff_map:
        _update_falloff()
