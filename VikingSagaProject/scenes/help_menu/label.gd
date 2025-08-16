extends Label

# This script fetches and displays the current Git branch name.
# It requires Git to be installed on the system where the game is run.

func _ready():
	# Define the command and arguments for the Git command.
	var command = "git"
	var arguments = ["rev-parse", "--abbrev-ref", "HEAD"]
	
	# Create an array to hold the output from the command.
	var output_array = []
	
	# Execute the command in a single line.
	# The arguments are: command, arguments, and the array to store output.
	# This avoids the type error by not including a separate 'blocking' boolean.
	var exit_code = OS.execute(command, arguments, output_array)
	
	# Check if the command executed successfully.
	if exit_code == 0:
		# If successful, get the output from the array and format the branch name.
		var branch_name = output_array[0].strip_edges()
		self.text = "Git Branch: " + branch_name
	else:
		# If the command fails, it's likely because Git is not installed or
		# the project is not a Git repository.
		self.text = "Git Branch: N/A"
