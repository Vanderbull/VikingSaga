# SoundManager.gd
# This script is designed to be a singleton (Autoload) for managing all audio in a Godot 4.4 project.
# To use it, save this file and then go to Project -> Project Settings -> Autoload.
# Add a new entry with Path set to this script and Node Name as "SoundManager".
# This will make the functions in this script globally accessible.

# NOTE: Ensure you have "Music" and "SFX" audio buses set up in the Audio tab.
# You can access the Audio tab from the bottom panel in the Godot editor.
# This script will not work correctly without these buses.

extends Node

# Reference to the AudioStreamPlayer nodes for music and sound effects.
# We will create these nodes dynamically in the _ready() function.
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var music_tween: Tween # Tween for fading music.
var snapshot_tween: Tween # Tween for fading between snapshots.

# A dictionary to hold multiple AudioStreamPlayer nodes for sound effects,
# allowing for sound effect polyphony (playing multiple SFX at once).
var sfx_pool: Array[AudioStreamPlayer] = []
# The maximum number of SFX that can be played at the same time.
const SFX_POOL_SIZE = 8
# A pointer to the next available SFX player in the pool.
var sfx_pool_index = 0

# Store the default volume values for our buses.
var music_volume_db = 0.0
var sfx_volume_db = 0.0

# Called when the node is added to the scene tree.
func _ready():
	# Set up the AudioStreamPlayer for music.
	music_player = AudioStreamPlayer.new()
	# It will play on the "Music" bus.
	music_player.bus = "Music"
	add_child(music_player)

	# Set up the pool of AudioStreamPlayer nodes for sound effects.
	for i in range(SFX_POOL_SIZE):
		var new_player = AudioStreamPlayer.new()
		new_player.bus = "SFX"
		sfx_pool.append(new_player)
		add_child(new_player)

	# Create a new Tween for music fading effects.
	music_tween = create_tween()
	music_tween.set_parallel(true)
	music_tween.kill()
	
	# Create a new Tween for snapshot fading effects.
	snapshot_tween = create_tween()
	snapshot_tween.set_parallel(true)
	snapshot_tween.kill()
	
	# Cache the initial volume values from the AudioServer.
	music_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sfx_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))

# ==============================================================================
# MUSIC FUNCTIONS
# ==============================================================================

# Play a music track. If a track is already playing, it will be replaced.
# @param music: The AudioStream to play. This can be a .ogg or .mp3 file.
# @param loop: Whether the music should loop indefinitely.
func play_music(music: AudioStream, loop: bool = true):
	# If the provided music is the same as the current, do nothing.
	if music_player.stream == music and music_player.playing:
		return
	
	music_player.stream = music
	music_player.stream_paused = false
	music_player.play()
	
	# Note: Godot 4.4 handles looping automatically for many stream types,
	# but we can also set the loop flag manually if needed.
	if music is AudioStreamOggVorbis:
		music.loop = loop

# Pause the currently playing music.
func pause_music():
	if music_player.playing:
		music_player.stream_paused = true

# Resume the paused music.
func resume_music():
	if music_player.stream_paused:
		music_player.stream_paused = false

# Stop the music.
func stop_music():
	music_player.stop()

# ==============================================================================
# MUSIC FADING FUNCTIONS
# ==============================================================================

# Fade in the currently playing music.
# @param duration: The duration of the fade in seconds.
# @param volume: The target linear volume (0.0-1.0) to fade to.
func fade_in_music(duration: float = 1.0, target_volume: float = 1.0):
	music_tween.kill()
	music_player.volume_db = linear_to_db(0.0) # Start from 0 volume
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", linear_to_db(target_volume), duration)

# Fade out the currently playing music.
# @param duration: The duration of the fade in seconds.
func fade_out_music(duration: float = 1.0):
	music_tween.kill()
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", linear_to_db(0.0), duration)
	music_tween.tween_callback(music_player.stop)

# ==============================================================================
# SOUND EFFECT FUNCTIONS
# ==============================================================================

# Play a sound effect.
# This function uses a pool of players to allow multiple SFX to play at once.
# It cycles through the pool to find an available player.
# @param sfx: The AudioStream to play.
func play_sfx(sfx: AudioStream):
	# Get the next available player from the pool.
	var player = sfx_pool[sfx_pool_index]
	
	# Set the stream and play it.
	player.stream = sfx
	player.play()
	
	# Move the index to the next player in the pool, wrapping around if needed.
	sfx_pool_index = (sfx_pool_index + 1) % SFX_POOL_SIZE
	
# Play a 2D spatial sound effect at a given position.
# This creates a temporary AudioStreamPlayer2D node, plays the sound, and
# automatically frees the node when the sound is finished.
# @param sfx: The AudioStream to play.
# @param position: The Vector2 position in the 2D world.
# @param bus_name: The name of the audio bus to use. Defaults to "SFX_2D".
func play_sfx_2d(sfx: AudioStream, position: Vector2, bus_name: String = "SFX_2D"):
	var player = AudioStreamPlayer2D.new()
	player.stream = sfx
	player.bus = bus_name
	player.position = position
	
	# Connect the "finished" signal to queue_free() to clean up the node.
	player.finished.connect(player.queue_free)
	
	# Get the main scene tree and add the player as a child.
	get_tree().root.add_child(player)
	player.play()

# Play a 3D spatial sound effect at a given position.
# This creates a temporary AudioStreamPlayer3D node, plays the sound, and
# automatically frees the node when the sound is finished.
# @param sfx: The AudioStream to play.
# @param position: The Vector3 position in the 3D world.
# @param bus_name: The name of the audio bus to use. Defaults to "SFX_3D".
func play_sfx_3d(sfx: AudioStream, position: Vector3, bus_name: String = "SFX_3D"):
	var player = AudioStreamPlayer3D.new()
	player.stream = sfx
	player.bus = bus_name
	player.global_position = position
	
	# Connect the "finished" signal to queue_free() to clean up the node.
	player.finished.connect(player.queue_free)

	# Get the main scene tree and add the player as a child.
	get_tree().root.add_child(player)
	player.play()

# ==============================================================================
# VOLUME CONTROL FUNCTIONS
# ==============================================================================

# Set the volume for the "Music" bus.
# @param volume: A float value between 0.0 and 1.0.
func set_music_volume(volume: float):
	# Convert the linear volume (0.0-1.0) to decibels for the audio bus.
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

# Set the volume for the "SFX" bus.
# @param volume: A float value between 0.0 and 1.0.
func set_sfx_volume(volume: float):
	# Convert the linear volume (0.0-1.0) to decibels for the audio bus.
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

# Get the current volume for the "Music" bus.
# @return The linear volume (0.0-1.0).
func get_music_volume() -> float:
	var bus_index = AudioServer.get_bus_index("Music")
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

# Get the current volume for the "SFX" bus.
# @return The linear volume (0.0-1.0).
func get_sfx_volume() -> float:
	var bus_index = AudioServer.get_bus_index("SFX")
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

# ==============================================================================
# ADVANCED AUDIO FEATURES
# ==============================================================================

# Apply an audio bus snapshot. This is useful for things like pausing the game
# or entering a menu, where you want to change the state of multiple buses at once.
# The volume of each bus will fade to the values defined in the snapshot over the
# specified duration.
# Snapshots must be created and saved in the Godot editor's Audio tab.
# @param snapshot: The AudioBusLayout to apply. This should be loaded from a
#                  snapshot file created in the editor.
# @param duration: The time in seconds to blend to the new snapshot.
func apply_snapshot(snapshot: AudioBusLayout, duration: float = 0.5):
	# Immediately apply the new bus layout.
	AudioServer.set_bus_layout(snapshot)

	# Kill any existing snapshot tween to prevent conflicts.
	snapshot_tween.kill()
	snapshot_tween = create_tween()

	# Iterate through all the buses and tween their volumes to the new values
	# from the snapshot.
	for i in range(AudioServer.bus_count):
		# Get the target volume from the snapshot.
		var target_volume_db = snapshot.get_bus_volume_db(i)
		
		# Get the current volume of the bus.
		var current_volume_db = AudioServer.get_bus_volume_db(i)
		
		# Tween the volume from the current value to the target value.
		snapshot_tween.tween_method(
			Callable(AudioServer, "set_bus_volume_db").bind(i),
			current_volume_db,
			target_volume_db,
			duration
		)
