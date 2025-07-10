extends Node

class_name PlayerWarmth

## Signals
signal warmth_changed(new_warmth: float)
signal warmth_low(threshold: float)
signal warmth_depleted()

## Exported variables for easy configuration in the editor
@export var initial_warmth: float = 100.0 : set = set_initial_warmth
@export var min_warmth: float = 0.0
@export var max_warmth: float = 100.0

@export var warmth_loss_rate: float = 5.0
@export var warmth_gain_rate: float = 10.0

@export var ambient_temperature: float = 20.0 # Celsius
@export var freezing_point: float = 0.0

@export var heat_detection_radius: float = 5.0
@export var heat_source_influence_factor: float = 1.0 # Multiplier for heat influence per source at zero distance

@export var insulation_factor: float = 1.0 : set = set_insulation_factor

@export var low_warmth_threshold: float = 20.0

## Internal variables
var current_warmth: float = 100.0
var heat_sources: Array[Node2D] = []

func _ready() -> void:
    current_warmth = clamp(initial_warmth, min_warmth, max_warmth)

func _process(delta: float) -> void:
    update_warmth(delta)

func update_warmth(delta: float) -> void:
    # Clean up invalid heat sources
    heat_sources = heat_sources.filter(is_instance_valid)
    
    var old_warmth = current_warmth
    var temperature_effect = ambient_temperature - freezing_point
    var heat_influence = get_heat_influence()
    
    # Base warmth change
    var warmth_change = 0.0
    
    if heat_influence > 0.0:
        warmth_change += heat_influence * warmth_gain_rate * (1.0 / insulation_factor) * delta  # Insulation slows gain too
    else:
        if temperature_effect < 0.0:
            # Cold environment drains warmth
            warmth_change -= (abs(temperature_effect) / 10.0) * warmth_loss_rate * (1.0 / insulation_factor) * delta
        else:
            # Slight warmth gain in warm areas
            warmth_change += (temperature_effect / 30.0) * warmth_gain_rate * delta
    
    set_warmth(current_warmth + warmth_change)
    
    # Emit signals if necessary
    if current_warmth != old_warmth:
        warmth_changed.emit(current_warmth)
    
    if current_warmth <= low_warmth_threshold and old_warmth > low_warmth_threshold:
        warmth_low.emit(low_warmth_threshold)
    
    if current_warmth <= min_warmth and old_warmth > min_warmth:
        warmth_depleted.emit()

## Calculates the total heat influence from nearby sources with falloff
func get_heat_influence() -> float:
    var influence: float = 0.0
    var player_pos = get_parent().global_position if get_parent() is Node2D else Vector2.ZERO
    
    for source in heat_sources:
        if not source:
            continue
        var dist = source.global_position.distance_to(player_pos)
        if dist <= heat_detection_radius:
            influence += (1.0 - (dist / heat_detection_radius)) * heat_source_influence_factor
    
    return influence

## Setter for initial warmth
func set_initial_warmth(value: float) -> void:
    initial_warmth = value
    current_warmth = clamp(initial_warmth, min_warmth, max_warmth)

## Getter for current warmth
func get_warmth() -> float:
    return current_warmth

## Setter for current warmth with clamping
func set_warmth(value: float) -> void:
    current_warmth = clamp(value, min_warmth, max_warmth)

## Setter for ambient temperature
func set_ambient_temperature(temp: float) -> void:
    ambient_temperature = temp

## Setter for insulation factor with clamping
func set_insulation_factor(factor: float) -> void:
    insulation_factor = clamp(factor, 0.1, 5.0)

## Add a heat source
func add_heat_source(source: Node2D) -> void:
    if source and not heat_sources.has(source):
        heat_sources.append(source)

## Remove a heat source
func remove_heat_source(source: Node2D) -> void:
    heat_sources.erase(source)
