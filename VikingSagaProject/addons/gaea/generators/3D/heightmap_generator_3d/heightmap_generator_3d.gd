@tool
class_name HeightmapGenerator3D
extends ChunkAwareGenerator3D
## Generates 3D terrain using an advanced heightmap system with noise and optional biomes
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(HeightmapGenerator): https://benjatk.github.io/Gaea/#/generators/heightmap

@export var settings: HeightmapGenerator3DSettings

# Performance tracking
var _generation_time: float = 0.0
var _processed_chunks: int = 0

## Generates the complete terrain
func generate(starting_grid: GaeaGrid = null) -> void:
	if Engine.is_editor_hint() and not editor_preview:
		push_warning("%s: Editor preview disabled, generation skipped" % name)
		return
	
	if not _validate_settings():
		return
	
	generation_started.emit()
	_processed_chunks = 0
	_generation_time = Time.get_ticks_msec()
	
	# Configure noise
	if settings.noise:
		settings.noise.seed = seed
	
	# Initialize grid
	if starting_grid == null:
		erase()
	else:
		grid = starting_grid.duplicate()  # Use duplicate to prevent modifying input
	
	_generate_full_terrain()
	_apply_modifiers(settings.modifiers)
	
	# Handle next pass
	if is_instance_valid(next_pass):
		next_pass.generate(grid)
	
	_report_generation_time()
	grid_updated.emit()
	generation_finished.emit()

## Generates a specific chunk of terrain
func generate_chunk(chunk_position: Vector3i, starting_grid: GaeaGrid = null) -> void:
	if Engine.is_editor_hint() and not editor_preview:
		push_warning("%s: Editor preview disabled, chunk generation skipped" % name)
		return
	
	if not _validate_settings():
		return
	
	if starting_grid == null:
		erase_chunk(chunk_position)
	else:
		grid = starting_grid.duplicate()
	
	_generate_chunk_terrain(chunk_position)
	_apply_modifiers_chunk(settings.modifiers, chunk_position)
	
	generated_chunks.append(chunk_position)
	_processed_chunks += 1
	
	if is_instance_valid(next_pass):
		if not next_pass is ChunkAwareGenerator3D:
			push_error("Next pass generator must be ChunkAwareGenerator3D")
		else:
			next_pass.generate_chunk(chunk_position, grid)
	
	# Deferred signals for thread safety
	(func(): chunk_updated.emit(chunk_position)).call_deferred()
	(func(): chunk_generation_finished.emit(chunk_position)).call_deferred()

## Generates the full terrain heightmap
func _generate_full_terrain() -> void:
	var area := _calculate_area_bounds(Vector3i.ZERO, Vector2i(settings.world_size))
	_process_area(area)

## Generates a chunk's terrain heightmap
func _generate_chunk_terrain(chunk_position: Vector3i) -> void:
	var chunk_world_size = Vector2i(settings.chunk_size.x, settings.chunk_size.y)
	var area := _calculate_area_bounds(chunk_position, chunk_world_size)
	_process_area(area)

## Calculates AABB bounds for generation area
func _calculate_area_bounds(position: Vector3i, size: Vector2i) -> AABB:
	var max_height := settings.max_height
	if settings.use_lod:
		max_height /= settings.lod_levels
	
	return AABB(
		Vector3i(position.x * size.x, settings.min_height, position.z * size.y),
		Vector3i(size.x, max_height - settings.min_height, size.y)
	)

## Processes terrain generation for a given area
func _process_area(area: AABB) -> void:
	for x in range(area.position.x, area.end.x):
		if not settings.infinite and (x < 0 or x >= settings.world_size.x):
			continue
		
		for z in range(area.position.z, area.end.z):
			if not settings.infinite and (z < 0 or z >= settings.world_size.y):
				continue
			
			var height = settings.get_height_at(x, z)
			if settings.use_lod:
				height = _apply_lod_to_height(height, Vector3i(x, height, z))
			
			for y in range(area.position.y, area.end.y):
				if y <= height and y >= settings.min_height:
					grid.set_valuexyz(x, y, z, settings.tile)
				elif y == height + 1 and settings.air_layer:
					grid.set_valuexyz(x, y, z, null)

## Applies LOD scaling to height
func _apply_lod_to_height(height: float, position: Vector3i) -> float:
	if not settings.use_lod:
		return height
	
	var distance = position.distance_to(Vector3i.ZERO)
	var lod_factor = clamp(distance / float(settings.world_size.x), 0.0, 1.0)
	return height / (1 + lod_factor * (settings.lod_levels - 1))

## Validates generator settings
func _validate_settings() -> bool:
	if not settings:
		push_error("%s: No settings resource assigned" % name)
		return false
	if not settings.tile:
		push_error("%s: No tile defined in settings" % name)
		return false
	return true

## Reports generation performance
func _report_generation_time() -> void:
	if OS.is_debug_build():
		var elapsed = (Time.get_ticks_msec() - _generation_time) / 1000.0
		#print("%s: Generated %d chunks in %.3f seconds" % [name, _processed_chunks, elapsed])

## Updates generator configuration when properties change
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE and Engine.is_editor_hint():
		if settings:
			settings.noise.seed = seed
			# Trigger regeneration in editor if needed
			if editor_preview:
				generate()

## Returns generator configuration as dictionary
func get_config() -> Dictionary:
	return {
		"settings": settings,
		"seed": seed,
		"editor_preview": editor_preview
	}
