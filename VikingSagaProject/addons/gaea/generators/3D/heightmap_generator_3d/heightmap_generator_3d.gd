@tool
class_name HeightmapGenerator3D
extends ChunkAwareGenerator3D
## Generates 3D terrain using an advanced heightmap system with noise, biomes, erosion, and LOD support
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(HeightmapGenerator): https://benjatk.github.io/Gaea/#/generators/heightmap

@export var settings: HeightmapGenerator3DSettings

# Performance tracking
var _generation_time: float = 0.0
var _processed_chunks: int = 0
var _thread_pool: ThreadPool = ThreadPool.new()  # Multi-threading support
var _cache: HeightmapCache = HeightmapCache.new()  # Cache for heightmap data

# Signals for advanced feedback
signal terrain_feature_added(feature_type: String, position: Vector3i)
signal performance_metrics_updated(metrics: Dictionary)

## Generates the complete terrain with optional threading
func generate(starting_grid: GaeaGrid = null, use_threads: bool = false) -> void:
    if Engine.is_editor_hint() and not editor_preview:
        push_warning("%s: Editor preview disabled, generation skipped" % name)
        return
    
    if not _validate_settings():
        return
    
    generation_started.emit()
    _processed_chunks = 0
    _generation_time = Time.get_ticks_msec()
    
    # Configure noise and seed
    if settings.noise:
        settings.noise.seed = seed
    
    # Initialize grid
    if starting_grid == null:
        erase()
    else:
        grid = starting_grid.duplicate()
    
    if use_threads and settings.enable_threading:
        _generate_full_terrain_threaded()
    else:
        _generate_full_terrain()
    
    _apply_modifiers(settings.modifiers)
    _apply_erosion()  # New erosion feature
    _generate_biome_features()  # New biome-specific features
    
    # Handle next pass
    if is_instance_valid(next_pass):
        next_pass.generate(grid)
    
    _report_generation_time()
    _emit_performance_metrics()
    grid_updated.emit()
    generation_finished.emit()

## Generates a specific chunk of terrain with optional threading
func generate_chunk(chunk_position: Vector3i, starting_grid: GaeaGrid = null, use_threads: bool = false) -> void:
    if Engine.is_editor_hint() and not editor_preview:
        push_warning("%s: Editor preview disabled, chunk generation skipped" % name)
        return
    
    if not _validate_settings():
        return
    
    if starting_grid == null:
        erase_chunk(chunk_position)
    else:
        grid = starting_grid.duplicate()
    
    if use_threads and settings.enable_threading:
        _generate_chunk_terrain_threaded(chunk_position)
    else:
        _generate_chunk_terrain(chunk_position)
    
    _apply_modifiers_chunk(settings.modifiers, chunk_position)
    _apply_erosion_chunk(chunk_position)  # Erosion for chunk
    _generate_biome_features_chunk(chunk_position)  # Biome features for chunk
    
    generated_chunks.append(chunk_position)
    _processed_chunks += 1
    
    if is_instance_valid(next_pass):
        if not next_pass is ChunkAwareGenerator3D:
            push_error("Next pass generator must be ChunkAwareGenerator3D")
        else:
            next_pass.generate_chunk(chunk_position, grid)
    
    # Deferred signals
    (func(): chunk_updated.emit(chunk_position)).call_deferred()
    (func(): chunk_generation_finished.emit(chunk_position)).call_deferred()

## Generates the full terrain heightmap
func _generate_full_terrain() -> void:
    var area := _calculate_area_bounds(Vector3i.ZERO, Vector2i(settings.world_size))
    _process_area(area)

## Generates full terrain using threads
func _generate_full_terrain_threaded() -> void:
    var chunk_size = settings.chunk_size
    var chunks_x = ceil(settings.world_size.x / float(chunk_size.x))
    var chunks_z = ceil(settings.world_size.y / float(chunk_size.y))
    
    for cx in range(chunks_x):
        for cz in range(chunks_z):
            var chunk_pos = Vector3i(cx, 0, cz)
            _thread_pool.queue_task(func(): _generate_chunk_terrain(chunk_pos))
    
    _thread_pool.wait_for_all_tasks()

## Generates a chunk's terrain heightmap
func _generate_chunk_terrain(chunk_position: Vector3i) -> void:
    var chunk_world_size = Vector2i(settings.chunk_size.x, settings.chunk_size.y)
    var area := _calculate_area_bounds(chunk_position, chunk_world_size)
    _process_area(area)

## Generates a chunk's terrain using threading
func _generate_chunk_terrain_threaded(chunk_position: Vector3i) -> void:
    _generate_chunk_terrain(chunk_position)
    _cache.store_chunk(chunk_position, grid)

## Calculates AABB bounds with biome consideration
func _calculate_area_bounds(position: Vector3i, size: Vector2i) -> AABB:
    var max_height := settings.max_height
    if settings.use_lod:
        max_height /= settings.lod_levels
    if settings.biome_map:
        max_height = _adjust_height_for_biome(position, max_height)
    
    return AABB(
        Vector3i(position.x * size.x, settings.min_height, position.z * size.y),
        Vector3i(size.x, max_height - settings.min_height, size.y)
    )

## Processes terrain generation for a given area with biome support
func _process_area(area: AABB) -> void:
    for x in range(area.position.x, area.end.x):
        if not settings.infinite and (x < 0 or x >= settings.world_size.x):
            continue
        
        for z in range(area.position.z, area.end.z):
            if not settings.infinite and (z < 0 or z >= settings.world_size.y):
                continue
            
            var height = _get_cached_or_calculate_height(x, z)
            if settings.use_lod:
                height = _apply_lod_to_height(height, Vector3i(x, height, z))
            
            var biome = _get_biome_at(x, z)
            for y in range(area.position.y, area.end.y):
                if y <= height and y >= settings.min_height:
                    var tile = biome.tile if biome else settings.tile
                    grid.set_valuexyz(x, y, z, tile)
                elif y == height + 1 and settings.air_layer:
                    grid.set_valuexyz(x, y, z, null)

## Applies erosion simulation to the full terrain
func _apply_erosion() -> void:
    if not settings.enable_erosion:
        return
    
    var iterations = settings.erosion_iterations
    for i in range(iterations):
        for x in range(settings.world_size.x):
            for z in range(settings.world_size.y):
                var height = grid.get_valuexyz(x, settings.min_height, z)
                if height != null:
                    var neighbors = _get_neighbor_heights(x, z)
                    var avg_height = _average_neighbor_height(neighbors)
                    if height > avg_height + settings.erosion_threshold:
                        grid.set_valuexyz(x, height - 1, z, null)
                        grid.set_valuexyz(x, height - 2, z, settings.tile)

## Applies erosion to a specific chunk
func _apply_erosion_chunk(chunk_position: Vector3i) -> void:
    if not settings.enable_erosion:
        return
    
    var area = _calculate_area_bounds(chunk_position, settings.chunk_size)
    for x in range(area.position.x, area.end.x):
        for z in range(area.position.z, area.end.z):
            var height = grid.get_valuexyz(x, settings.min_height, z)
            if height != null:
                var neighbors = _get_neighbor_heights(x, z)
                var avg_height = _average_neighbor_height(neighbors)
                if height > avg_height + settings.erosion_threshold:
                    grid.set_valuexyz(x, height - 1, z, null)
                    grid.set_valuexyz(x, height - 2, z, settings.tile)

## Generates biome-specific features (e.g., trees, rocks)
func _generate_biome_features() -> void:
    if not settings.biome_map:
        return
    
    for x in range(settings.world_size.x):
        for z in range(settings.world_size.y):
            var biome = _get_biome_at(x, z)
            if biome and biome.features.size() > 0 and randf() < biome.feature_density:
                var height = _get_cached_or_calculate_height(x, z)
                var feature = biome.features[randi() % biome.features.size()]
                _place_feature(feature, Vector3i(x, height + 1, z))

## Generates biome features for a chunk
func _generate_biome_features_chunk(chunk_position: Vector3i) -> void:
    if not settings.biome_map:
        return
    
    var area = _calculate_area_bounds(chunk_position, settings.chunk_size)
    for x in range(area.position.x, area.end.x):
        for z in range(area.position.z, area.end.z):
            var biome = _get_biome_at(x, z)
            if biome and biome.features.size() > 0 and randf() < biome.feature_density:
                var height = _get_cached_or_calculate_height(x, z)
                var feature = biome.features[randi() % biome.features.size()]
                _place_feature(feature, Vector3i(x, height + 1, z))

## Places a feature at a position
func _place_feature(feature: Resource, position: Vector3i) -> void:
    grid.set_valuexyz(position.x, position.y, position.z, feature)
    terrain_feature_added.emit(feature.resource_name, position)

## Gets or calculates height with caching
func _get_cached_or_calculate_height(x: int, z: int) -> float:
    var cached_height = _cache.get_height(x, z)
    if cached_height != null:
        return cached_height
    var height = settings.get_height_at(x, z)
    _cache.store_height(x, z, height)
    return height

## Adjusts height based on biome
func _adjust_height_for_biome(position: Vector3i, base_height: float) -> float:
    if not settings.biome_map:
        return base_height
    var biome = _get_biome_at(position.x, position.z)
    return base_height * (biome.height_multiplier if biome else 1.0)

## Gets biome at a position
func _get_biome_at(x: int, z: int) -> BiomeSettings:
    if not settings.biome_map:
        return null
    return settings.biome_map.get_biome_at(x, z, settings.noise)

## Gets neighboring heights for erosion
func _get_neighbor_heights(x: int, z: int) -> Array:
    var neighbors = []
    for dx in [-1, 0, 1]:
        for dz in [-1, 0, 1]:
            if dx == 0 and dz == 0:
                continue
            var nx = x + dx
            var nz = z + dz
            if nx >= 0 and nx < settings.world_size.x and nz >= 0 and nz < settings.world_size.y:
                var height = grid.get_valuexyz(nx, settings.min_height, nz)
                neighbors.append(height if height != null else settings.min_height)
    return neighbors

## Calculates average neighbor height
func _average_neighbor_height(neighbors: Array) -> float:
    if neighbors.size() == 0:
        return settings.min_height
    var total: float = 0.0
    for h in neighbors:
        total += h
    return total / neighbors.size()

## Applies LOD scaling to height
func _apply_lod_to_height(height: float, position: Vector3i) -> float:
    if not settings.use_lod:
        return height
    
    var distance = position.distance_to(Vector3i.ZERO)
    var lod_factor = clamp(distance / float(settings.world_size.x), 0.0, 1.0)
    return height / (1 + lod_factor * (settings.lod_levels - 1))

## Validates generator settings with additional checks
func _validate_settings() -> bool:
    if not settings:
        push_error("%s: No settings resource assigned" % name)
        return false
    if not settings.tile:
        push_error("%s: No tile defined in settings" % name)
        return false
    if settings.chunk_size.x <= 0 or settings.chunk_size.y <= 0:
        push_error("%s: Invalid chunk size" % name)
        return false
    if settings.world_size.x <= 0 or settings.world_size.y <= 0:
        push_error("%s: Invalid world size" % name)
        return false
    return true

## Reports generation performance
func _report_generation_time() -> void:
    if OS.is_debug_build():
        var elapsed = (Time.get_ticks_msec() - _generation_time) / 1000.0
        print("%s: Generated %d chunks in %.3f seconds" % [name, _processed_chunks, elapsed])

## Emits detailed performance metrics
func _emit_performance_metrics() -> void:
    var elapsed = (Time.get_ticks_msec() - _generation_time) / 1000.0
    var metrics = {
        "chunks_generated": _processed_chunks,
        "time_seconds": elapsed,
        "chunks_per_second": _processed_chunks / max(elapsed, 0.001),
        "thread_count": _thread_pool.active_threads() if settings.enable_threading else 1
    }
    performance_metrics_updated.emit(metrics)

## Updates generator configuration in editor
func _notification(what: int) -> void:
    if what == NOTIFICATION_EDITOR_PRE_SAVE and Engine.is_editor_hint():
        if settings:
            settings.noise.seed = seed
            if editor_preview:
                generate(null, false)

## Returns generator configuration as dictionary
func get_config() -> Dictionary:
    return {
        "settings": settings,
        "seed": seed,
        "editor_preview": editor_preview,
        "cache_enabled": _cache.is_enabled()
    }

## Clears the cache
func clear_cache() -> void:
    _cache.clear()

## Custom ThreadPool class (simplified implementation)
class ThreadPool:
    var threads: Array[Thread] = []
    var tasks: Array[Callable] = []
    var mutex: Mutex = Mutex.new()
    var semaphore: Semaphore = Semaphore.new()
    var active: bool = true
    
    func _init() -> void:
        var thread_count = OS.get_processor_count() - 1
        for i in range(thread_count):
            var thread = Thread.new()
            thread.start(_worker.bind(i))
            threads.append(thread)
    
    func queue_task(task: Callable) -> void:
        mutex.lock()
        tasks.append(task)
        mutex.unlock()
        semaphore.post()
    
    func wait_for_all_tasks() -> void:
        while true:
            mutex.lock()
            var is_done = tasks.size() == 0
            mutex.unlock()
            if is_done:
                break
            await Engine.get_main_loop().process_frame
    
    func active_threads() -> int:
        return threads.size()
    
    func _worker(id: int) -> void:
        while active:
            semaphore.wait()
            mutex.lock()
            if tasks.size() > 0:
                var task = tasks.pop_front()
                mutex.unlock()
                task.call()
            else:
                mutex.unlock()
    
    func _exit_tree() -> void:
        active = false
        for thread in threads:
            semaphore.post()
        for thread in threads:
            thread.wait_to_finish()

## Custom HeightmapCache class
class HeightmapCache:
    var heights: Dictionary = {}  # {Vector2i(x, z): float}
    var enabled: bool = true
    
    func store_height(x: int, z: int, height: float) -> void:
        if enabled:
            heights[Vector2i(x, z)] = height
    
    func get_height(x: int, z: int) -> Variant:
        return heights.get(Vector2i(x, z), null)
    
    func store_chunk(chunk_pos: Vector3i, chunk_grid: GaeaGrid) -> void:
        if enabled:
            # Simplified: store chunk data (could expand to full grid serialization)
            pass
    
    func clear() -> void:
        heights.clear()
    
    func is_enabled() -> bool:
        return enabled
