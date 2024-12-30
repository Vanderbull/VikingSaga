extends Node2D

# Variables
@export var warmth_radius: float = 200.0 # Radius of warmth
@export var warmth_power: float = 10.0 # Warmth added per second

# Area2D setup
func _ready():
	pass

func _process(delta):
	# Optional: Logic to reduce warmth radius over time (e.g., fire burning out)
	pass

# Fire script
signal warmth_effected(player)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("warmth_effected", body)
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("warmth_effected", null)
