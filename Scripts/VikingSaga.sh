#!/bin/bash
# This script launches the VikingSaga game executable.
# It sets the terminal title, ensures the executable is present and executable,
# and provides user feedback and configuration options.

# Function to log messages with timestamps
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Reset the terminal and set the default window title
echo -ne '\033c\033]0;ForbiddenLands\a'

# Determine the directory in which this script is located
base_path="$(dirname "$(realpath "$0")")"

# Define the path to the executable relative to the script's location
executable="$base_path/VikingSaga.x86_64"

# Check if the executable exists
if [ ! -f "$executable" ]; then
    log "Error: Executable not found: $executable" >&2
    exit 1
fi

# Check if the executable has execute permissions
if [ ! -x "$executable" ]; then
    log "Error: Executable does not have execute permissions: $executable" >&2
    exit 1
fi

# Allow users to set a custom window title via environment variable
if [ -n "$CUSTOM_TITLE" ]; then
    echo -ne "\033]0;$CUSTOM_TITLE\a"
fi

# Provide feedback to the user
log "Launching VikingSaga..."

# Launch the executable with all passed arguments, replacing the shell process
exec "$executable" "$@"

# Fallback error handling if exec fails (rare, as exec typically replaces the process)
if [ $? -ne 0 ]; then
    log "Error: Failed to launch the game. Check the game logs for more information." >&2
    exit 1
fi
