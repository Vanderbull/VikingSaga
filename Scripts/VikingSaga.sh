#!/bin/bash
# Enhanced launcher script for ForbiddenLands with auto-labeling capabilities

# Configuration variables
readonly TITLE="ForbiddenLands"
readonly EXECUTABLE_NAME="VikingSaga.x86_64"
readonly LOG_FILE="$HOME/.forbiddenlands/launch.log"
readonly CONFIG_FILE="$HOME/.forbiddenlands/config.conf"
readonly ASSET_DIR="assets"
readonly LABEL_FILE="$HOME/.forbiddenlands/asset_labels.json"
readonly REQUIRED_SPACE_MB=500
readonly VERSION="1.2.0"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Default configuration
declare -A CONFIG=(
    [auto_label]=true
    [update_check]=true
    [verbose]=false
)

# Log message function
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$timestamp] $1" >> "$LOG_FILE"
    [[ "${CONFIG[verbose]}" == "true" ]] && echo "[$timestamp] $1"
}

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ -n "$key" && "$key" != "#"* ]] && CONFIG["${key// /}"]="${value// /}"
        done < "$CONFIG_FILE"
    fi
}

# Save configuration
save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    printf "# ForbiddenLands Launcher Config\n" > "$CONFIG_FILE"
    for key in "${!CONFIG[@]}"; do
        printf "%s=%s\n" "$key" "${CONFIG[$key]}" >> "$CONFIG_FILE"
    done
}

# Check system requirements
check_requirements() {
    local free_space=$(df -m "$base_path" 2>/dev/null | tail -1 | awk '{print $4}')
    if [[ -z "$free_space" || "$free_space" -lt "$REQUIRED_SPACE_MB" ]]; then
        echo -e "${RED}Error: Insufficient disk space (${free_space:-0}MB available, ${REQUIRED_SPACE_MB}MB required)${NC}" >&2
        log_message "Insufficient disk space: ${free_space:-0}MB available"
        return 1
    fi

    [[ -z "$TERM" || "$TERM" = "dumb" ]] && {
        echo -e "${YELLOW}Warning: Limited terminal environment${NC}" >&2
        log_message "Limited terminal environment detected"
    }
    return 0
}

# Setup environment
setup_environment() {
    echo -ne "\033c\033]0;${TITLE}\a"
    export LD_LIBRARY_PATH="$base_path/lib:$LD_LIBRARY_PATH"
    export GAME_DIR="$base_path"
}

# Auto-label assets
auto_label_assets() {
    if [[ "${CONFIG[auto_label]}" != "true" ]]; then
        log_message "Auto-labeling disabled"
        return 0
    fi

    local asset_path="$base_path/$ASSET_DIR"
    [[ ! -d "$asset_path" ]] && {
        log_message "Asset directory not found: $asset_path"
        return 0
    }

    log_message "Starting asset auto-labeling"
    mkdir -p "$(dirname "$LABEL_FILE")"

    # Simple labeling based on file extension and name patterns
    local json="{"
    for file in "$asset_path"/*; do
        [[ ! -f "$file" ]] && continue
        local filename=$(basename "$file")
        local label="unknown"
        
        case "$filename" in
            *.png|*.jpg|*.tga) 
                [[ "$filename" =~ sprite ]] && label="sprite" || label="texture"
                ;;
            *.ogg|*.wav) label="audio";;
            *.glb|*.obj) label="model";;
            *.txt|*.json) label="data";;
        esac
        
        json+="\"$filename\":\"$label\","
    done
    
    # Remove trailing comma and close JSON
    json="${json%,}}"
    echo "$json" > "$LABEL_FILE"
    log_message "Asset labeling complete. Labels saved to $LABEL_FILE"
}

# Check for updates
check_updates() {
    if [[ "${CONFIG[update_check]}" != "true" || ! $(command -v curl) ]]; then
        log_message "Update check skipped"
        return 0
    fi
    
    local latest=$(curl -s "https://example.com/latest_version" 2>/dev/null || echo "$VERSION")
    if [[ "$latest" != "$VERSION" ]]; then
        echo -e "${YELLOW}Update available: v$latest (current: v$VERSION)${NC}"
        log_message "Update available: v$latest"
    fi
}

# Main execution
main() {
    local base_path="$(dirname "$(realpath "$0")")"
    local executable="$base_path/$EXECUTABLE_NAME"

    load_config
    log_message "Starting $TITLE launcher (v$VERSION)"
    echo -e "${GREEN}Launching $TITLE (v$VERSION)${NC}"

    # Run checks and setup
    check_requirements || exit 1
    auto_label_assets
    check_updates
    setup_environment
    log_message "Environment setup completed"

    # Verify executable
    [[ ! -f "$executable" ]] && {
        echo -e "${RED}Error: Executable not found: $executable${NC}" >&2
        log_message "Executable not found: $executable"
        exit 1
    }

    [[ ! -x "$executable" ]] && {
        echo -e "${YELLOW}Warning: Fixing executable permissions${NC}"
        chmod +x "$executable" || {
            echo -e "${RED}Error: Failed to make executable: $executable${NC}" >&2
            log_message "Failed to set execute permissions"
            exit 1
        }
        log_message "Fixed executable permissions"
    }

    # Launch game
    if command -v time >/dev/null 2>&1; then
        /usr/bin/time -f "Launch time: %E" "$executable" "$@" 2>> "$LOG_FILE"
    else
        exec "$executable" "$@"
    fi

    local exit_code=$?
    log_message "Game exited with code $exit_code"
    [[ $exit_code -ne 0 ]] && echo -e "${YELLOW}Warning: Game exited with code $exit_code${NC}" >&2
    exit $exit_code
}

# Signal handling
trap 'log_message "Launcher interrupted"; exit 1' INT TERM

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -h, --help         Show this help message"
            echo "  -v, --version      Show version information"
            echo "  -l, --label        Force asset labeling"
            echo "  --no-label         Disable auto-labeling"
            echo "  --verbose          Enable verbose output"
            exit 0
            ;;
        -v|--version)
            echo "$TITLE Launcher v$VERSION"
            exit 0
            ;;
        -l|--label)
            CONFIG[auto_label]=true
            auto_label_assets
            exit 0
            ;;
        --no-label)
            CONFIG[auto_label]=false
            ;;
        --verbose)
            CONFIG[verbose]=true
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Run main function
main "$@"
