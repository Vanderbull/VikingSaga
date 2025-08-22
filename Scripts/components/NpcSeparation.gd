extends Node
class_name NpcSeparation

## How far to look for neighbors (px)
@export var radius: float = 28.0
## How strongly to push away (bigger = stronger)
@export var weight: float = 240.0
## Physics layer mask containing NPCs (set to your NPC layer)
@export var npc_mask: int = 1 << 2

var _shape := CircleShape2D.new()

func _ready() -> void:
	_shape.radius = radius

## Returns a separation force you can add to your NPC’s velocity each frame.
func get_separation(owner: Node2D) -> Vector2:
	var space_state := owner.get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = _shape
	params.transform = Transform2D(0.0, owner.global_position)
	params.collision_mask = npc_mask
	params.exclude = [owner]

	var hits := space_state.intersect_shape(params, 16)
	var force := Vector2.ZERO
	for hit in hits:
		var other := hit.collider as Node2D
		if other:
			var away := owner.global_position - other.global_position
			var d := maxf(1.0, away.length())
			force += away / (d * d) # inverse-square falloff
	return force * weight
