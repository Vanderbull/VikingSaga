extends Node3D
class_name World

@onready var generator = $HeightmapGenerator
@onready var chunk_loader = $ChunkLoader
@onready var player = $Player

func _ready():
    if Engine.is_editor_hint():
        generator.generate()
    else:
        # Initial chunk loading handled by ChunkLoader
        pass

func _on_generator_finished():
    if Engine.is_editor_hint():
        print("World generation completed in editor")
    else:
        # Additional initialization for runtime
        _adjust_player_start_position()

func _adjust_player_start_position():
    if generator.grid and player:
        var center_x = generator.settings.world_size.x / 2
        var center_z = generator.settings.world_size.y / 2
        var height = generator.settings.get_height_at(center_x, center_z)
        player.global_position = Vector3(center_x, height + 2.0, center_z)
