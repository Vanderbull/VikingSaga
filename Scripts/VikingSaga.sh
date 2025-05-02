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
  echo "Error: Executable not found: $executable" >&2
  exit 1
fi

# Check if the executable has execute permissions, attempt to fix if missing
if [ ! -x "$executable" ]; then
  echo "Error: Executable does not have execute permissions: $executable" >&2
  echo "Attempting to set execute permissions..."
  chmod +x "$executable"
  if [ $? -ne 0 ]; then
    echo "Failed to set execute permissions. Please run 'chmod +x $executable' manually." >&2
    exit 1
  fi
  echo "Execute permissions set successfully."
fi

# Check for required dependencies (e.g., libGL for graphical games)
if ! command -v glxinfo > /dev/null 2>&1; then
  echo "Warning: libGL not found. The game may not run properly." >&2
  echo "Consider installing mesa-utils or your system's equivalent package."
fi

# Set environment variables (e.g., LD_LIBRARY_PATH for custom libraries)
if [ -d "$base_path/lib" ]; then
  export LD_LIBRARY_PATH="$base_path/lib:$LD_LIBRARY_PATH"
  echo "Added $base_path/lib to LD_LIBRARY_PATH."
fi

# Parse command-line options
fullscreen=false
resolution=""
log_file="$base_path/game_launch.log"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --fullscreen)
      fullscreen=true
      shift
      ;;
    --resolution)
      resolution="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

# Build argument list for the executable
args=()
if [ "$fullscreen" = true ]; then
  args+=("--fullscreen")
fi
if [ -n "$resolution" ]; then
  args+=("--resolution" "$resolution")
fi

# Log the launch attempt
echo "[$(date)] Launching ForbiddenLands from $executable" >> "$log_file"
echo "Launching ForbiddenLands..."

# Launch the executable with parsed arguments and remaining arguments
exec "$executable" "${args[@]}" "$@"

# If exec fails (rare, as it replaces the shell process), report an error
echo "Error: Failed to launch the executable." >&2
exit 1
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