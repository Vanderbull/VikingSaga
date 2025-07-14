extends Control
@onready var minimap_texture_rect = $Minimap
@onready var minimap_marker = $Minimap/Marker
@onready var minimap_viewport = $Minimap/SubViewport
@onready var player = $"../../world/TileMap/Player"

# Define the bounds of the world and the minimap for scaling
var world_size = Vector2(2000, 2000)  # Example: World size in game units (adjust to your world)
var minimap_size = Vector2(256, 256) # Minimap size calculation

func _ready():
	# Ensure the marker has a texture assigned
	if minimap_marker.texture == null:
		print("No texture assigned to marker!")
	else:
		print("Marker texture assigned.")

	# Update the marker position initially
	update_marker_position()

func _process(_delta):
	# Update the marker position every frame
	update_marker_position()

func update_marker_position():
	# Get the player's position in world coordinates (example assumes player has a position property)
	var player_position = player.position

	# Convert the player's world position to minimap coordinates
	var minimap_position = player_position / world_size * minimap_size

	# Clamp the minimap position to stay within the minimap bounds
	minimap_position.x = clamp(minimap_position.x, 0, minimap_size.x - minimap_marker.texture.get_size().x * minimap_marker.scale.x)
	minimap_position.y = clamp(minimap_position.y, 0, minimap_size.y - minimap_marker.texture.get_size().y * minimap_marker.scale.y)

	# Set the new position of the marker
	minimap_marker.position = minimap_position
