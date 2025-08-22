extends Node
class_name TerrainQuery

## Link to your ground TileMap (set in editor or via code)
@export var ground_map: TileMap
## Name of the custom data key in your tileset (bool)
@export var key_walkable := "walkable"
## Optional: movement penalty map key (number)
@export var key_move_penalty := "move_penalty"

func is_walkable_at_world(world_pos: Vector2) -> bool:
	if ground_map == null:
		return true
	var cell := ground_map.local_to_map(ground_map.to_local(world_pos))
	var data := ground_map.get_cell_tile_data(0, cell) # layer 0 by default
	if data == null:
		return true
	# If key absent, default to true (walkable)
	return bool(data.get_custom_data(key_walkable, true))

func move_penalty_at_world(world_pos: Vector2) -> float:
	if ground_map == null:
		return 1.0
	var cell := ground_map.local_to_map(ground_map.to_local(world_pos))
	var data := ground_map.get_cell_tile_data(0, cell)
	if data == null:
		return 1.0
	return float(data.get_custom_data(key_move_penalty, 1.0))
