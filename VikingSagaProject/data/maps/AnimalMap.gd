extends TileMap

# Node references with proper typing
@onready var globals: Node = get_node("/root/Globals")
@onready var player: Node2D = $"../TileMap/Player"
@onready var tile_info_label: Label = $"../../TileInfoWindow/PanelContainer/VBoxContainer/TileAnimals"

# Constants
const DEFAULT_ANIMAL_TEXT: String = "ANIMALS: None"
const LAYER_ID: int = 0

# Function to check if a tile exists at a specific grid position
func is_tile_set(tile_position: Vector2i) -> bool:
    return get_cell_source_id(LAYER_ID, tile_position) != -1

# Initialize the tile map
func _ready() -> void:
    print("AnimalMap initialized...")
    tile_info_label.text = DEFAULT_ANIMAL_TEXT

# Process tile information each frame
func _process(_delta: float) -> void:
    var tile_pos: Vector2i = local_to_map(player.position)
    update_tile_info(tile_pos)

# Centralized function to update tile information
func update_tile_info(tile_pos: Vector2i) -> void:
    if not is_tile_set(tile_pos):
        tile_info_label.text = DEFAULT_ANIMAL_TEXT
        return

    var source_id: int = get_cell_source_id(LAYER_ID, tile_pos)
    if source_id == -1:  # More explicit check than null
        push_warning("Invalid source ID at position: ", tile_pos)
        return

    var tile_source: TileSetSource = tile_set.get_source(source_id)
    if not tile_source:
        push_warning("Tile source not found for ID: ", source_id)
        return

    # Using atlas coordinate (0,1) as per original code
    var tile_data: TileData = tile_source.get_tile_data(Vector2i(0, 1), 0)
    if not tile_data:
        push_warning("Tile data not found at position: ", tile_pos)
        return

    var animal_type: String = tile_data.get_custom_data("type") as String
    if animal_type.is_empty():
        tile_info_label.text = DEFAULT_ANIMAL_TEXT
    else:
        tile_info_label.text = "ANIMALS: %s" % animal_type
        print("Animal detected at %s: %s" % [tile_pos, animal_type])

# Helper function to validate setup
func validate_nodes() -> bool:
    if not globals:
        push_error("Globals node not found")
        return false
    if not player:
        push_error("Player node not found")
        return false
    if not tile_info_label:
        push_error("Tile info label not found")
        return false
    return true
