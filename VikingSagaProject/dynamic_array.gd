extends Node

var dynamic_array: Array = []

# Function to add an element to the dynamic array
func add_element(element):
	dynamic_array.append(element)
	#if Engine.is_debug_build():
	print_debug("Added element:", element)
	print_debug("Current array:", dynamic_array)

# Function to print the contents of the dynamic array
func print_array():
	#if Engine.is_debug_build():
	print_debug("Array contents:", dynamic_array)

func _ready():

	# Accessing an element
	# var element = grid[row_index][col_index]

	# Modifying an element
	# grid[row_index][col_index] = new_value
	
	# Initialize the grid with empty arrays (rows)
	for i in range(3):
		var row: Array = []
		for j in range(3):
			# Initialize each element in the row with a placeholder value
			row.append(0)
		# Add the row to the grid
		dynamic_array.append(row)
		
	for i in range(dynamic_array.size()):
		print_debug("Row ", i, ": ", dynamic_array[i])
	# Adding elements to the array
	#add_element(10)
	#add_element(20)
	#add_element(30)
	
	# Printing the array contents
	#print_array()

