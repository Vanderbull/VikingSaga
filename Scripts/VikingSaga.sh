#!/bin/sh
# Reset the terminal and set the window title to "ForbiddenLands"
echo -ne '\033c\033]0;ForbiddenLands\a'

# Determine the directory in which this script is located.
base_path="$(dirname "$(realpath "$0")")"

# Define the path to the executable relative to the script's location.
executable="$base_path/VikingSaga.x86_64"

# Check if the executable exists and has execute permissions.
if [ ! -x "$executable" ]; then
  echo "Error: Executable not found or not executable: $executable" >&2
  exit 1
fi

# Launch the executable with all passed arguments,
# replacing this shell process with the new process.
exec "$executable" "$@"
