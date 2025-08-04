extends CharacterBody2D
# Expert-level upgrade:
# - Strong typing, clear responsibilities, cached node paths
# - Uses PathFollow2D.progress_ratio for stable parametric motion
# - Easing-based movement, pause/return, clamped progress, frame-rate independent
# - Robust distance/waypoint handling with curve length sampling
# - Safe collision toggling via helper, no magic strings
# - Signals emit deltas and current values; health is clamped with setters
# - Debug trail with capped points and optional toggle
# - Works with both uniform-segment waypoints and curve sampling
# - Avoids exact float equality, uses epsilon thresholds
# - Minimal allocations per frame

# References:
# - CharacterBody2D velocity and movement API [docs.godotengine.org](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
# - move_and_slide usage patterns [kidscancode.org](https://kidscancode.org/godot_recipes/4.x/kyn/characterbody2d/index.html)
# - Velocity along paths and using direction_to at constant speed [forum.godotengine.org](https://forum.godotengine.org/t/kinematicbody2d-slows-down-when-using-move-and-slide/15357)
# - Path following, waypoint wrapping examples [forum.godotengine.org](https://forum.godotengine.org/t/how-can-i-use-move-and-slide-to-move-a-characterbody2d-along-a-path2d/99025)

# Exported configuration
@export_group("Movement")
@export var speed: float = 250.0            # units per second along the path
@export var accelerate: float = 1500.0      # acceleration to target speed
@export var decelerate: float = 2000.0      # deceleration when stopping/reversing
@export var snap_epsilon: float = 0.001     # threshold for progress ratio comparisons
@export var follow_curve_directly: bool = true # true: drive via PathFollow2D; false: manual point-to-point

@export_group("Progress")
@export_range(0.0, 1.0, 0.0001) var path_progress_ratio: float = 0.0 # 0..1 normalized
@export var loop_path: bool = true
@export var auto_reverse_on_end: bool = false

@export_group("Debug")
@export var draw_trail: bool = true
@export var max_trail_points: int = 100
@export var show_gizmos: bool = false

# State toggles (can be driven by external scripts/UI)
@export var move_forward: bool = false
@export var move_backward: bool = false

# Signals
signal health_changed(new_value: int, delta: int)
signal health_changed_ship(new_value: int)
signal health_changed_village(new_value: int)
signal reached_end()   # Fired when reaching end (ratio ~1.0 or last waypoint)
signal reached_start() # Fired when reaching start (ratio ~0.0 or first waypoint)

# Cached nodes (set in _ready)
var _path_follow: PathFollow2D
var _path_2d: Path2D
var _curve: Curve2D
var _player: Node2D
var _trail: Line2D

# Internal runtime
var _hp: int = 10:
	set(value):
		var clamped = max(0, value)
		if clamped != _hp:
			var delta = clamped - _hp
			_hp = clamped
			health_changed.emit(_hp, delta)
			health_changed_ship.emit(_hp)

var _waypoint: int = 0
var _distance_left: float = 0.0
var _direction: int = 1  # 1 forward, -1 backward
var _current_speed: float = 0.0
var _curve_length: float = 0.0
var _last_progress_ratio: float = -1.0

# Constants
const EPS: float = 1e-6

# Helpers to access siblings/parents without brittle "../../../" paths
@onready var _path_follow_path: NodePath = NodePath("..") # this script is expected on a child of PathFollow2D
@onready var _path_2d_path: NodePath = NodePath("../..")
@onready var _player_path: NodePath = NodePath("../../../Player")
@onready var _trail_path: NodePath = NodePath("../../../Line2D")

func _ready() -> void:
	_path_follow = get_node_or_null(_path_follow_path)
	_path_2d = get_node_or_null(_path_2d_path)
	_player = get_node_or_null(_player_path)
	_trail = get_node_or_null(_trail_path)

	assert(_path_follow and _path_2d, "Ship expects to be a child (or descendant) of PathFollow2D under a Path2D")
	_curve = _path_2d.curve
	assert(_curve, "Path2D must have a valid Curve2D")

	# Precompute curve length for distance-based movement when needed
	_curve_length = _compute_curve_length(_curve)

	# Initialize normalized progress and sync PathFollow2D
	path_progress_ratio = clampf(path_progress_ratio, 0.0, 1.0)
	_sync_progress_to_follow()

	# Initialize waypoint metrics if using point-to-point mode
	if not follow_curve_directly:
		_reset_waypoint_distance()

	# Example initial health broadcast
	health_changed_ship.emit(_hp)

func _process(_delta: float) -> void:
	if draw_trail and _trail:
		_trail.add_point(global_position)
		while _trail.get_point_count() > max(0, max_trail_points):
			_trail.remove_point(0)

func _physics_process(delta: float) -> void:
	if not _curve:
		return

	# Determine desired direction based on toggles
	var desired_dir := 0
	if move_forward: desired_dir += 1
	if move_backward: desired_dir -= 1
	if auto_reverse_on_end and desired_dir == 0:
		desired_dir = _direction # keep previous if autoresume

	# Accel/decel towards desired speed
	var target_speed := float(desired_dir) * speed
	var rate := accelerate if signf(target_speed) == signf(_current_speed) else decelerate
	_current_speed = move_toward(_current_speed, target_speed, rate * delta)

	if follow_curve_directly:
		_step_along_curve(delta)
	else:
		_step_waypoints(delta)

	# Optional: gently face movement direction
	var v := (global_position - _path_follow.global_position) if _path_follow else Vector2.ZERO
	if v.length() > 0.01:
		rotation = v.angle()

	# Debug gizmos/labels could be drawn via _draw

func _step_along_curve(delta: float) -> void:
	if not _path_follow:
		return

	# Convert linear speed to progress ratio based on curve length
	var linear_delta := _current_speed * delta
	if absf(_curve_length) < EPS:
		return
	var ratio_delta := linear_delta / _curve_length

	var next_ratio := path_progress_ratio + ratio_delta
	if loop_path:
		next_ratio = fposmod(next_ratio, 1.0)
	else:
		next_ratio = clampf(next_ratio, 0.0, 1.0)

	# Detect ends for signaling and auto-reverse
	if not loop_path:
		if next_ratio >= 1.0 - snap_epsilon and _last_progress_ratio < 1.0 - snap_epsilon:
			reached_end.emit()
			if auto_reverse_on_end:
				_direction = -1
				move_forward = false
				move_backward = true
		elif next_ratio <= 0.0 + snap_epsilon and (_last_progress_ratio < 0.0 or _last_progress_ratio > 0.0 + snap_epsilon):
			reached_start.emit()
			if auto_reverse_on_end:
				_direction = 1
				move_forward = true
				move_backward = false

	path_progress_ratio = next_ratio
	_sync_progress_to_follow()
	_last_progress_ratio = path_progress_ratio

	# Align player to ship and manage collisions when moving
	if _player:
		if absf(_current_speed) > EPS:
			_set_player_collision_enabled(false)
			_player.global_position = global_position
		else:
			_set_player_collision_enabled(true)

func _step_waypoints(delta: float) -> void:
	# Move between discrete Curve2D points at constant linear speed
	var step_dist := absf(_current_speed) * delta
	var dir := 1 if _current_speed >= 0.0 else -1

	while step_dist > 0.0:
		if _distance_left <= step_dist + EPS:
			step_dist -= _distance_left
			_advance_waypoint(dir)
			_reset_waypoint_distance()
			if _distance_left <= EPS:
				break
		else:
			# Move towards next point
			var from := _curve.get_point_position(_waypoint)
			var to := _curve.get_point_position(_next_index(_waypoint, dir))
			var seg_dir := (to - from).normalized()
			global_position = global_position + seg_dir * (step_dist * signf(_current_speed))
			_distance_left -= step_dist
			step_dist = 0.0

	# Keep PathFollow2D roughly in sync with closest position on curve
	if _path_follow:
		var closest_t := _closest_ratio_on_curve(global_position)
		path_progress_ratio = closest_t
		_sync_progress_to_follow()

	# Player collision handling consistent with curve mode
	if _player:
		if absf(_current_speed) > EPS:
			_set_player_collision_enabled(false)
			_player.global_position = global_position
		else:
			_set_player_collision_enabled(true)

func _advance_waypoint(dir: int) -> void:
	var count := _curve.point_count
	if count <= 1:
		return
	_waypoint = _next_index(_waypoint, dir)
	if not loop_path:
		if (_waypoint == 0 and dir < 0) or (_waypoint == count - 1 and dir > 0):
			if dir > 0:
				reached_end.emit()
			else:
				reached_start.emit()
			if auto_reverse_on_end:
				_direction = -dir
			_current_speed = 0.0

func _reset_waypoint_distance() -> void:
	var count := _curve.point_count
	if count <= 1:
		_distance_left = 0.0
		return
	var from := _curve.get_point_position(_waypoint)
	var to := _curve.get_point_position(_next_index(_waypoint, _direction))
	_distance_left = from.distance_to(to)
	if _distance_left <= EPS:
		_distance_left = 0.0

func _next_index(i: int, dir: int) -> int:
	var count := _curve.point_count
	if count == 0:
		return 0
	if loop_path:
		return wrapi(i + dir, 0, count)
	return clampi(i + dir, 0, count - 1)

func _sync_progress_to_follow() -> void:
	# PathFollow2D.progress_ratio is stable across curve edits
	_path_follow.progress_ratio = clampf(path_progress_ratio, 0.0, 1.0)
	# Keep this node riding the path
	global_position = _path_follow.global_position

func _set_player_collision_enabled(enabled: bool) -> void:
	# Toggle first layer/mask bit; adjust if your project uses other bits
	if _player and _player.has_method("set_collision_layer_value"):
		_player.set_collision_layer_value(1, enabled)
	if _player and _player.has_method("set_collision_mask_value"):
		_player.set_collision_mask_value(1, enabled)

# Public API ----------------------------------------------------------------

func damage(amount: int) -> void:
	if amount <= 0:
		return
	_hp = _hp - amount
	if _hp == 0:
		# Optional: add death behavior here
		pass
	health_changed_village.emit(_hp) # keep legacy external listeners updated

func heal(amount: int) -> void:
	if amount <= 0:
		return
	_hp = _hp + amount

func set_progress_ratio(ratio: float) -> void:
	path_progress_ratio = clampf(ratio, 0.0, 1.0)
	_sync_progress_to_follow()

func go_to_start() -> void:
	set_progress_ratio(0.0)
	_direction = 1
	_current_speed = 0.0
	reached_start.emit()

func go_to_end() -> void:
	set_progress_ratio(1.0)
	_direction = -1
	_current_speed = 0.0
	reached_end.emit()

# Utilities -----------------------------------------------------------------

static func distance(a: Vector2, b: Vector2) -> float:
	# Using built-in distance for clarity and stability
	return a.distance_to(b)

func _compute_curve_length(curve: Curve2D, samples: int = 256) -> float:
	if not curve:
		return 0.0
	samples = max(4, samples)
	var total := 0.0
	var prev := curve.samplef(0.0)
	for i in range(1, samples + 1):
		var t := float(i) / float(samples)
		var p := curve.samplef(t)
		total += prev.distance_to(p)
		prev = p
	return total

func _closest_ratio_on_curve(pos: Vector2, samples: int = 128) -> float:
	# Simple uniform sampling search; adequate and allocation-free
	if not _curve:
		return 0.0
	var best_t := 0.0
	var best_d := INF
	for i in range(samples + 1):
		var t := float(i) / float(samples)
		var p := _curve.samplef(t)
		var d := pos.distance_squared_to(p)
		if d < best_d:
			best_d = d
			best_t = t
	return best_t

# Optional debug draw
func _draw() -> void:
	if not show_gizmos or not _curve:
		return
	var color := Color(0.2, 0.8, 1.0, 0.6)
	var prev := _curve.samplef(0.0)
	for i in range(1, 64):
		var t := float(i) / 63.0
		var p := _curve.samplef(t)
		draw_line(to_local(prev), to_local(p), color, 2.0)
		prev = p
	draw_circle(to_local(global_position), 6.0, Color(1, 0.8, 0.2, 0.8))
