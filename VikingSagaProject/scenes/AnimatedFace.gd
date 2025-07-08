extends AnimatedSprite2D

# Exported variables for easy tweaking in the editor
@export var default_animation: String = "default"  # Default animation to play
@export var auto_play: bool = true                # Whether to auto-play on ready
@export var loop_animation: bool = true           # Whether animations should loop
@export var fade_in_duration: float = 0.5         # Duration for fade-in effect

# Internal variables
var is_active: bool = false                       # Tracks if the face is active
var original_scale: Vector2                       # Stores the original scale for effects

# Signals for external scripts to connect to
signal animation_finished_custom(anim_name)      # Custom signal for animation end

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Store the original scale
	original_scale = scale
	
	# Set up initial state
	if auto_play:
		play(default_animation)
	else:
		stop()
	
	# Connect the built-in animation finished signal
	animation_finished.connect(_on_animation_finished)
	
	# Start hidden with a fade-in effect
	modulate.a = 0.0
	hide()
	_fade_in()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_active and not visible:
		show()
	
	# Optional: Add subtle idle scaling effect
	if is_active:
		var scale_offset = sin(Time.get_ticks_msec() * 0.001) * 0.05
		scale = original_scale * (1.0 + scale_offset)

# Fade-in effect using a tween
func _fade_in() -> void:
	is_active = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	tween.tween_callback(show)

# Function to play a specific animation with optional speed
func play_animation(anim_name: String, speed: float = 1.0) -> void:
	if animation != anim_name or not is_playing():
		speed_scale = speed
		play(anim_name)

# Function to toggle visibility with a fade effect
func toggle_visibility(fade_duration: float = 0.5) -> void:
	var tween = create_tween()
	if visible:
		tween.tween_property(self, "modulate:a", 0.0, fade_duration)
		tween.tween_callback(hide)
		is_active = false
	else:
		show()
		tween.tween_property(self, "modulate:a", 1.0, fade_duration)
		is_active = true

# Function to apply a temporary scale effect (e.g., for emphasis)
func pulse_effect(duration: float = 0.3, strength: float = 1.2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * strength, duration / 2)
	tween.tween_property(self, "scale", original_scale, duration / 2)

# Callback for when an animation finishes
func _on_animation_finished() -> void:
	if not loop_animation:
		stop()
		is_active = false
		toggle_visibility()
	emit_signal("animation_finished_custom", animation)

# Function to change animation based on an external condition (e.g., health)
func update_expression(state: String) -> void:
	match state:
		"happy":
			play_animation("happy")
		"sad":
			play_animation("sad")
		"angry":
			play_animation("angry")
		_:
			play_animation(default_animation)

# Optional: Handle input for testing or interaction
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Example: Spacebar or Enter
		pulse_effect()
	elif event.is_action_pressed("ui_cancel"):  # Example: Escape
		toggle_visibility()
