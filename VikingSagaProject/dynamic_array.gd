extends Node

# Dictionary to store the coordinates with text
var coordinates_with_text = {}

# Function to generate coordinates with text
func generate_coordinates_with_text():
	for x in range(-1000, 1001):
		for y in range(-1000, 1001):
			var position = Vector2(x, y)
			var text = "Coordinate: (" + str(x) + ", " + str(y) + ")"
			coordinates_with_text[position] = text

# Function to find text by x and y
func find_coordinate_with_text(x: int, y: int) -> String:
	var position = Vector2(x, y)
	if position in coordinates_with_text:
		return coordinates_with_text[position]
	return "Coordinate not found"

func _ready():
	# Call the function to generate the coordinates with text
	generate_coordinates_with_text()
	
	# Example of finding a specific coordinate
	#var result = find_coordinate_with_text(100, 200)
	#print(result)
	# Output will be: "Coordinate: (100, 200)"

	#var result_not_found = find_coordinate_with_text(2000, 2000)
	#print(result_not_found)
	# Output will be: "Coordinate not found"

