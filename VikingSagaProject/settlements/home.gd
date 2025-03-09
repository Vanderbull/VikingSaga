extends Area2D
class_name MovingEntity

## Configurable movement speed in pixels per second
@export var speed: float = 20.0
## Movement limit threshold (0 to 1) for reaching endpoint
@export_range(0.0, 1.0) var limit: float = 0.5
## Target endpoint for movement
@export var end_point: NodePath = NodePath("")
## Entity's identifying name
@export var identity: String = "Village"
## Initial health points
@export_range(1, 100) var max_health: int = 6
## Movement pattern type
@export_enum("Linear", "PingPong", "Circular") var movement_type: String = "Linear"

# Runtime variables
@onready var hp: int = max_health
@onready var label: Label = $Identity
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
var start_position: Vector2
var target_position: Vector2
var is_moving_forward: bool = true
var movement_progress: float = 0.0

# Signals
signal health_changed(new_hp: int, max_hp: int)
signal reached_endpoint(entity_name: String)
signal damaged(amount: int)

func _ready() -> void:
    # Initialize positions
    start_position = global_position
    if end_point:
        var end_node = get_node_or_null(end_point)
        target_position = end_node.global_position if end_node else start_position
    
    # Setup UI
    if label:
        label.text = identity
    
    # Validate components
    if not animation_player:
        push_warning("No AnimationPlayer found for %s" % name)
    if not sprite:
        push_warning("No Sprite2D found for %s" % name)

func _physics_process(delta: float) -> void:
    if not end_point or not is_moving():
        return
    
    match movement_type:
        "Linear":
            _move_linear(delta)
        "PingPong":
            _move_ping_pong(delta)
        "Circular":
            _move_circular(delta)
    
    # Update UI
    if label:
        label.text = identity

func _move_linear(delta: float) -> void:
    var direction = (target_position - global_position).normalized()
    var distance = speed * delta
    
    if global_position.distance_to(target_position) > limit:
        global_position += direction * distance
    else:
        reached_endpoint.emit(identity)
        set_physics_process(false)

func _move_ping_pong(delta: float) -> void:
    movement_progress += delta * speed / start_position.distance_to(target_position)
    if movement_progress >= 1.0 or movement_progress <= 0.0:
        is_moving_forward = !is_moving_forward
        movement_progress = clamp(movement_progress, 0.0, 1.0)
    
    var target = target_position if is_moving_forward else start_position
    global_position = global_position.lerp(target, movement_progress)

func _move_circular(delta: float) -> void:
    var center = (start_position + target_position) / 2
    var radius = start_position.distance_to(target_position) / 2
    movement_progress += delta * speed / (2 * PI * radius)
    
    var angle = movement_progress * 2 * PI
    global_position = center + Vector2(cos(angle), sin(angle)) * radius

func take_damage(amount: int) -> void:
    hp = clamp(hp - amount, 0, max_health)
    health_changed.emit(hp, max_health)
    damaged.emit(amount)
    
    if animation_player and animation_player.has_animation("damage"):
        animation_player.play("damage")
    
    if hp <= 0:
        _die()

func heal(amount: int) -> void:
    hp = clamp(hp + amount, 0, max_health)
    health_changed.emit(hp, max_health)

func _die() -> void:
    if animation_player and animation_player.has_animation("death"):
        await animation_player.play("death")
    queue_free()

func is_moving() -> bool:
    return speed > 0 and global_position.distance_to(target_position) > limit

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("player_attack"):
        take_damage(1)

# Editor preview
func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if not $Identity:
        warnings.append("Missing Identity Label node")
    if not end_point:
        warnings.append("No endpoint specified")
    return warnings
