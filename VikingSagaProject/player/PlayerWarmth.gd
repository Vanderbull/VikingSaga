extends Node
class_name PlayerWarmth

@export var current_warmth: float = 0.65     # designer-friendly start value
@export var min_warmth: float = 0.0
@export var max_warmth: float = 1.0
@export var heat_group: StringName = &"heat_source"
@export var base_cool_rate: float = 0.015    # per second without heat
@export var heat_scale: float = 1200.0       # tweak feel of falloff
@export var clamp_decay: bool = true

func _process(delta: float) -> void:
	var gain := _heat_gain(global_position)
	var loss := base_cool_rate
	var delta_w := gain * delta - loss * delta
	current_warmth = clampf(current_warmth + delta_w, min_warmth, max_warmth)

func _heat_gain(pos: Vector2) -> float:
	var nodes := get_tree().get_nodes_in_group(heat_group)
	var total := 0.0
	for n in nodes:
		var m := n as Node2D
		if m == null: continue
		var d := maxf(1.0, pos.distance_to(m.global_position))
		# Inverse-square falloff, scaled so designers can feel differences
		total += heat_scale / (d * d)
	return total
