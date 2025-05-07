extends CharacterBody2D

@export var speed: float = 100.0
@export var entity_name: String = "Default Name" : set = set_entity_name

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_animation: String = ""

func _ready() -> void:
    set_entity_name(entity_name) # Set initial name
    # If not using autoplay in AnimationPlayer or want to control it here:
    # play_animation("idle_pulse")

func set_entity_name(new_name: String) -> void:
    entity_name = new_name
    if name_label:
        name_label.text = entity_name

func _physics_process(delta: float) -> void:
    # Example movement (replace with your actual logic)
    var direction := Vector2.ZERO
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1

    if direction != Vector2.ZERO:
        velocity = direction.normalized() * speed
        play_animation("walk") # Assumes you have a walk animation
        # Flip sprite based on direction
        if direction.x != 0:
            sprite_2d.flip_h = direction.x < 0
    else:
        velocity = Vector2.ZERO
        play_animation("idle_pulse") # Assumes you have an idle animation

    move_and_slide()

func play_animation(anim_name: String) -> void:
    if animation_player and animation_player.has_animation(anim_name):
        if current_animation != anim_name: # Only play if it's a new animation
            animation_player.play(anim_name)
            current_animation = anim_name
    else:
        printerr("AnimationPlayer or animation not found: ", anim_name)
