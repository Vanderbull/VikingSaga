extends Resource
class_name BiomeClassifier

@export var water_level: float = 0.28
@export var cold_threshold: float = 0.35
@export var hot_threshold: float = 0.70

enum { BIOME_WATER, BIOME_COLD, BIOME_TEMPERATE, BIOME_HOT }

func classify(height01: float, heat01: float) -> int:
	if height01 < water_level:
		return BIOME_WATER
	if heat01 < cold_threshold:
		return BIOME_COLD
	if heat01 > hot_threshold:
		return BIOME_HOT
	return BIOME_TEMPERATE
