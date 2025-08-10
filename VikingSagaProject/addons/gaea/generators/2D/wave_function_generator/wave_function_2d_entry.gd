@tool
class_name WaveFunction2DEntry
extends Resource
## Describes a TileInfo and which tiles can neighbor it for Wave Function Collapse (2D).
## Designed for Godot 4.x.
## Features:
## - Typed neighbor lists (cardinal + optional diagonals)
## - Symmetry helpers (mirror up/down, left/right)
## - Validation + normalization utilities
## - Convenience API (get/add/remove/check neighbors by direction or offset)
## - Metadata (tags, notes) and serialization helpers
## - Weight clamped to >= 0
## - Optional self-neighbor policy

# ───────────────────────────────────────────────────────────────────────────────
# METADATA / CORE
# ───────────────────────────────────────────────────────────────────────────────

## The TileInfo to be placed when this entry is chosen.
## IMPORTANT: Assign a stable `id: StringName` on the TileInfo itself.
@export var tile_info: TileInfo

## A higher weight means a higher chance of being chosen to be placed.
## Clamped to >= 0.0 in `_clamp_weight`.
@export_range(0.0, 1_000.0, 0.01, "or_greater") var weight: float = 1.0

## Optional free-form labels (useful to filter tiles by biome/theme).
@export var tags: PackedStringArray = PackedStringArray()

## Editor notes.
@export_multiline var notes: String = ""

# ───────────────────────────────────────────────────────────────────────────────
# RULE FLAGS
# ───────────────────────────────────────────────────────────────────────────────
@export_category("Rules")

## If true, automatically allow this tile to neighbor itself on all permitted sides
## during `normalize()` (added/removed according to this flag).
@export var allow_self_neighbors: bool = true

## If true, treat left/right neighbor sets as mirrored (they will be synchronized by `normalize()`).
@export var symmetric_lr: bool = false

## If true, treat up/down neighbor sets as mirrored (they will be synchronized by `normalize()`).
@export var symmetric_ud: bool = false

## If true, also enable and validate diagonal neighbor constraints.
@export var use_diagonals: bool = false

# ───────────────────────────────────────────────────────────────────────────────
# NEIGHBOR CONSTRAINTS (CARDINAL)
# ───────────────────────────────────────────────────────────────────────────────
@export_group("Valid Neighbors (Cardinal)", "neighbors_")
## Valid neighbors above the tile, using their TileInfo's `id`.
@export var neighbors_up: Array[StringName] = []
## Valid neighbors below the tile, using their TileInfo's `id`.
@export var neighbors_down: Array[StringName] = []
## Valid neighbors left to the tile, using their TileInfo's `id`.
@export var neighbors_left: Array[StringName] = []
## Valid neighbors right to the tile, using their TileInfo's `id`.
@export var neighbors_right: Array[StringName] = []

# ───────────────────────────────────────────────────────────────────────────────
# NEIGHBOR CONSTRAINTS (DIAGONAL, OPTIONAL)
# ───────────────────────────────────────────────────────────────────────────────
@export_group("Valid Neighbors (Diagonals Optional)", "neighbors_diag_")
@export var neighbors_diag_up_left: Array[StringName] = []
@export var neighbors_diag_up_right: Array[StringName] = []
@export var neighbors_diag_down_left: Array[StringName] = []
@export var neighbors_diag_down_right: Array[StringName] = []

# ───────────────────────────────────────────────────────────────────────────────
# DIRECTION ENUMS / MAPS
# ───────────────────────────────────────────────────────────────────────────────
enum Side { UP, RIGHT, DOWN, LEFT }
enum Diagonal { UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT }

const SIDE_TO_OFFSET := {
	Side.UP: Vector2i(0, -1),
	Side.RIGHT: Vector2i(1, 0),
	Side.DOWN: Vector2i(0, 1),
	Side.LEFT: Vector2i(-1, 0),
}

const DIAG_TO_OFFSET := {
	Diagonal.UP_LEFT: Vector2i(-1, -1),
	Diagonal.UP_RIGHT: Vector2i(1, -1),
	Diagonal.DOWN_LEFT: Vector2i(-1, 1),
	Diagonal.DOWN_RIGHT: Vector2i(1, 1),
}

# ───────────────────────────────────────────────────────────────────────────────
# EDITOR QoL ACTIONS
# ───────────────────────────────────────────────────────────────────────────────
@export_category("Actions")
## Click in the inspector to normalize (dedupe + symmetry + self policy).
@export var normalize_now := false:
	set(value):
		if value:
			normalize()
		normalize_now = false

## Click in the inspector to run validations (prints warnings in the Editor Output).
@export var validate_now := false:
	set(value):
		if value:
			validate(true)
		validate_now = false

# ───────────────────────────────────────────────────────────────────────────────
# LIFECYCLE / EDITOR
# ───────────────────────────────────────────────────────────────────────────────

func _init() -> void:
	# Ensure sane startup defaults
	_clamp_weight()

func _clamp_weight() -> void:
	if weight < 0.0:
		weight = 0.0

# ───────────────────────────────────────────────────────────────────────────────
# HELPERS
# ───────────────────────────────────────────────────────────────────────────────

func get_tile_id() -> StringName:
	## Returns this entry's tile id, or empty if unset.
	if tile_info == null:
		return StringName("")
	return tile_info.id if "id" in tile_info else StringName("")

func _dedupe(arr: Array[StringName]) -> Array[StringName]:
	var seen := {}
	var out: Array[StringName] = []
	for id in arr:
		if not seen.has(id):
			seen[id] = true
			out.append(id)
	return out

func _ensure_in(arr: Array[StringName], id: StringName, include: bool) -> Array[StringName]:
	var out := _dedupe(arr)
	var idx := out.find(id)
	if include and idx == -1:
		out.append(id)
	elif not include and idx != -1:
		out.remove_at(idx)
	return out

func _get_side_array(side: Side) -> Array[StringName]:
	match side:
		Side.UP: return neighbors_up
		Side.RIGHT: return neighbors_right
		Side.DOWN: return neighbors_down
		Side.LEFT: return neighbors_left
	return []

func _set_side_array(side: Side, data: Array[StringName]) -> void:
	match side:
		Side.UP: neighbors_up = data
		Side.RIGHT: neighbors_right = data
		Side.DOWN: neighbors_down = data
		Side.LEFT: neighbors_left = data

func _get_diag_array(diag: Diagonal) -> Array[StringName]:
	match diag:
		Diagonal.UP_LEFT: return neighbors_diag_up_left
		Diagonal.UP_RIGHT: return neighbors_diag_up_right
		Diagonal.DOWN_LEFT: return neighbors_diag_down_left
		Diagonal.DOWN_RIGHT: return neighbors_diag_down_right
	return []

func _set_diag_array(diag: Diagonal, data: Array[StringName]) -> void:
	match diag:
		Diagonal.UP_LEFT: neighbors_diag_up_left = data
		Diagonal.UP_RIGHT: neighbors_diag_up_right = data
		Diagonal.DOWN_LEFT: neighbors_diag_down_left = data
		Diagonal.DOWN_RIGHT: neighbors_diag_down_right = data

# ───────────────────────────────────────────────────────────────────────────────
# PUBLIC API
# ───────────────────────────────────────────────────────────────────────────────

## Returns the neighbor list for a cardinal side.
func get_neighbors(side: Side) -> Array[StringName]:
	return _get_side_array(side).duplicate()

## Returns the neighbor list for a diagonal direction (if enabled).
func get_neighbors_diag(diag: Diagonal) -> Array[StringName]:
	return _get_diag_array(diag).duplicate()

## Adds a neighbor id to a cardinal side.
func add_neighbor(side: Side, id: StringName) -> void:
	var data := _get_side_array(side)
	data.append(id)
	_set_side_array(side, _dedupe(data))

## Adds a neighbor id to a diagonal direction (if enabled).
func add_neighbor_diag(diag: Diagonal, id: StringName) -> void:
	var data := _get_diag_array(diag)
	data.append(id)
	_set_diag_array(diag, _dedupe(data))

## Removes a neighbor id from a cardinal side.
func remove_neighbor(side: Side, id: StringName) -> void:
	var data := _get_side_array(side)
	var idx := data.find(id)
	if idx != -1:
		data.remove_at(idx)
	_set_side_array(side, data)

## Returns true if `neighbor_id` is allowed at `offset` relative to this tile.
## Supports both cardinals and diagonals (if `use_diagonals` is true).
func allows_neighbor_offset(offset: Vector2i, neighbor_id: StringName) -> bool:
	if offset == Vector2i.ZERO:
		return false
	# Cardinal
	for s in Side.values():
		if SIDE_TO_OFFSET[s] == offset:
			return _get_side_array(s).has(neighbor_id)
	# Diagonals
	if use_diagonals:
		for d in Diagonal.values():
			if DIAG_TO_OFFSET[d] == offset:
				return _get_diag_array(d).has(neighbor_id)
	return false

## Normalize this entry:
## - Deduplicate all lists
## - Apply symmetry (lr/ud)
## - Enforce self-neighbor policy
## - Clamp weight
func normalize() -> void:
	var id := get_tile_id()
	neighbors_up = _dedupe(neighbors_up)
	neighbors_right = _dedupe(neighbors_right)
	neighbors_down = _dedupe(neighbors_down)
	neighbors_left = _dedupe(neighbors_left)

	if use_diagonals:
		neighbors_diag_up_left = _dedupe(neighbors_diag_up_left)
		neighbors_diag_up_right = _dedupe(neighbors_diag_up_right)
		neighbors_diag_down_left = _dedupe(neighbors_diag_down_left)
		neighbors_diag_down_right = _dedupe(neighbors_diag_down_right)

	# Symmetry
	if symmetric_lr:
		neighbors_right = neighbors_left.duplicate()
	if symmetric_ud:
		neighbors_down = neighbors_up.duplicate()

	# Self policy
	if id != StringName(""):
		for s in Side.values():
			_set_side_array(s, _ensure_in(_get_side_array(s), id, allow_self_neighbors))
		if use_diagonals:
			for d in Diagonal.values():
				_set_diag_array(d, _ensure_in(_get_diag_array(d), id, allow_self_neighbors))

	_clamp_weight()

## Validate this entry and print warnings/errors to the console.
## Returns `true` if no errors were found.
func validate(print_to_console := true) -> bool:
	var ok := true
	var id := get_tile_id()

	if tile_info == null:
		ok = false
		if print_to_console: push_error("[WaveFunction2DEntry] Missing `tile_info`.")
	elif id == StringName(""):
		ok = false
		if print_to_console: push_error("[WaveFunction2DEntry] `tile_info.id` is empty (StringName).")

	if weight < 0.0:
		ok = false
		if print_to_console: push_warning("[WaveFunction2DEntry] `weight` < 0; it will be clamped to 0.")

	# Cardinal lists must be set; warn if empty (often fine, but suspicious).
	if neighbors_up.is_empty() and print_to_console:
		push_warning("[WaveFunction2DEntry] `neighbors_up` is empty.")
	if neighbors_right.is_empty() and print_to_console:
		push_warning("[WaveFunction2DEntry] `neighbors_right` is empty.")
	if neighbors_down.is_empty() and print_to_console:
		push_warning("[WaveFunction2DEntry] `neighbors_down` is empty.")
	if neighbors_left.is_empty() and print_to_console:
		push_warning("[WaveFunction2DEntry] `neighbors_left` is empty.")

	# Diagonal checks
	if use_diagonals:
		if neighbors_diag_up_left.is_empty() and print_to_console:
			push_warning("[WaveFunction2DEntry] `neighbors_diag_up_left` is empty (diagonals enabled).")
		if neighbors_diag_up_right.is_empty() and print_to_console:
			push_warning("[WaveFunction2DEntry] `neighbors_diag_up_right` is empty (diagonals enabled).")
		if neighbors_diag_down_left.is_empty() and print_to_console:
			push_warning("[WaveFunction2DEntry] `neighbors_diag_down_left` is empty (diagonals enabled).")
		if neighbors_diag_down_right.is_empty() and print_to_console:
			push_warning("[WaveFunction2DEntry] `neighbors_diag_down_right` is empty (diagonals enabled).")

	return ok

## Return all neighbors grouped by direction in a Dictionary.
func get_all_neighbors_dict() -> Dictionary:
	var out := {
		"up": neighbors_up.duplicate(),
		"right": neighbors_right.duplicate(),
		"down": neighbors_down.duplicate(),
		"left": neighbors_left.duplicate(),
	}
	if use_diagonals:
		out["up_left"] = neighbors_diag_up_left.duplicate()
		out["up_right"] = neighbors_diag_up_right.duplicate()
		out["down_left"] = neighbors_diag_down_left.duplicate()
		out["down_right"] = neighbors_diag_down_right.duplicate()
	return out

## Serialize this entry to a lightweight Dictionary (for persistence/tools).
func to_dict() -> Dictionary:
	return {
		"id": str(get_tile_id()),
		"weight": weight,
		"tags": tags.duplicate(),
		"flags": {
			"allow_self_neighbors": allow_self_neighbors,
			"symmetric_lr": symmetric_lr,
			"symmetric_ud": symmetric_ud,
			"use_diagonals": use_diagonals,
		},
		"neighbors": get_all_neighbors_dict(),
		"notes": notes,
	}

## Build a new entry from a TileInfo (with default permissive self-neighbor).
static func from_tile_info(ti: TileInfo, base_weight: float = 1.0) -> WaveFunction2DEntry:
	var e := WaveFunction2DEntry.new()
	e.tile_info = ti
	e.weight = maxf(0.0, base_weight)
	e.allow_self_neighbors = true
	return e
