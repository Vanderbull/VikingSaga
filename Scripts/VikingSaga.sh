#!/bin/bash
# Enhanced launcher script for ForbiddenLands game

# Configuration variables
readonly TITLE="ForbiddenLands"
readonly EXECUTABLE_NAME="VikingSaga.x86_64"
readonly LOG_FILE="$HOME/.forbiddenlands/launch.log"
readonly REQUIRED_SPACE_MB=500  # Minimum free disk space in MB
readonly VERSION="1.1.0"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'  # No Color

# Function to log messages with timestamp
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to check system requirements
check_requirements() {
    # Check disk space
    local free_space=$(df -m "$base_path" | tail -1 | awk '{print $4}')
    if [ "$free_space" -lt "$REQUIRED_SPACE_MB" ]; then
        echo -e "${RED}Error: Insufficient disk space (${free_space}MB available, ${REQUIRED_SPACE_MB}MB required)${NC}" >&2
        log_message "Insufficient disk space: ${free_space}MB available"
        return 1
    fi

    # Check if running in a compatible terminal
    if [ -z "$TERM" ] || [ "$TERM" = "dumb" ]; then
        echo -e "${YELLOW}Warning: Running in a limited terminal environment${NC}" >&2
        log_message "Limited terminal environment detected"
    fi
    return 0
}

# Function to set up environment
setup_environment() {
    # Reset terminal and set window title
    echo -ne "\033c\033]0;${TITLE}\a"
    
    # Set up game-specific environment variables
    export LD_LIBRARY_PATH="$base_path/lib:$LD_LIBRARY_PATH"
    export GAME_DIR="$base_path"
}

# Main execution
main() {
    # Get script's base directory
    local base_path
    base_path="$(dirname "$(realpath "$0")")"
    local executable="$base_path/$EXECUTABLE_NAME"

    # Log startup
    log_message "Starting $TITLE launcher (v$VERSION)"
    echo -e "${GREEN}Launching $TITLE (v$VERSION)${NC}"

    # Check system requirements
    if ! check_requirements; then
        exit 1
    fi

    # Verify executable
    if [ ! -f "$executable" ]; then
        echo -e "${RED}Error: Executable not found: $executable${NC}" >&2
        log_message "Executable not found: $executable"
        exit 1
    fi

    if [ ! -x "$executable" ]; then
        echo -e "${YELLOW}Warning: Executable lacks execute permissions, attempting to fix${NC}"
        if ! chmod +x "$executable"; then
            echo -e "${RED}Error: Failed to make executable: $executable${NC}" >&2
            log_message "Failed to set execute permissions on $executable"
            exit 1
        fi
        log_message "Added execute permissions to $executable"
    fi

    # Check for updates (placeholder - implement your update logic here)
    if command -v curl >/dev/null 2>&1; then
        log_message "Update check available but not implemented"
        # Example: curl -s "https://example.com/version" > version_check
    fi

    # Setup environment
    setup_environment
    log_message "Environment setup completed"

    # Launch game with performance monitoring
    if command -v time >/dev/null 2>&1; then
        /usr/bin/time -f "Launch time: %E" "$executable" "$@" 2>> "$LOG_FILE"
    else
        exec "$executable" "$@"
    fi

    local exit_code=$?
    log_message "Game exited with code $exit_code"
    
    if [ $exit_code -ne 0 ]; then
        echo -e "${YELLOW}Warning: Game exited with code $exit_code${NC}" >&2
    fi
    
    exit $exit_code
}

# Trap signals for cleanup
trap 'log_message "Launcher interrupted"; exit 1' INT TERM

# Parse command-line options
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -h, --help    Show this help message"
            echo "  -v, --version Show version information"
            exit 0
            ;;
        -v|--version)
            echo "$TITLE Launcher v$VERSION"
            exit 0
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Run main function with all remaining arguments
main "$@"
