extends Node

class_name PlayerWarmth

# Warmth settings
var current_warmth: float = 100.0 # Max 100
var min_warmth: float = 0.0
var max_warmth: float = 100.0

# Rates of change (units per second)
var warmth_loss_rate: float = 5.0
var warmth_gain_rate: float = 10.0

# Environmental influence
var ambient_temperature: float = 20.0 # Celsius
var freezing_point: float = 0.0
var heat_sources: Array = [] # Nodes or positions with heat

# Player clothing (affects insulation)
var insulation_factor: float = 1.0 # 0 = no clothes, 2 = heavy coat

func _process(delta: float) -> void:
	update_warmth(delta)

func update_warmth(delta: float) -> void:
	var temperature_effect = ambient_temperature - freezing_point
	var heat_nearby = is_near_heat_source()

	# Base warmth change
	var warmth_change = 0.0

	if heat_nearby:
		warmth_change += warmth_gain_rate * delta
	elif temperature_effect < 0.0:
		# Cold environment drains warmth
		warmth_change -= (abs(temperature_effect) / 10.0) * warmth_loss_rate * (1.0 / insulation_factor) * delta
	else:
		# Slight warmth gain in warm areas
		warmth_change += (temperature_effect / 30.0) * warmth_gain_rate * delta

	current_warmth = clamp(current_warmth + warmth_change, min_warmth, max_warmth)

func is_near_heat_source(radius: float = 5.0) -> bool:
	for source in heat_sources:
		if source and source.global_position.distance_to(get_parent().global_position) <= radius:
			return true
	return false

func set_ambient_temperature(temp: float) -> void:
	ambient_temperature = temp

func set_insulation(factor: float) -> void:
	insulation_factor = clamp(factor, 0.1, 5.0)

func add_heat_source(source: Node2D) -> void:
	heat_sources.append(source)

func remove_heat_source(source: Node2D) -> void:
	heat_sources.erase(source)
