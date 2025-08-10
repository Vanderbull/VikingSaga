#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# VikingSaga Launcher (enhanced)
# - Safer error handling (set -Eeuo pipefail)
# - XDG-aware logs with rotation
# - Optional dependency checks (ldd/glxinfo)
# - Config via env file (~/.config/VikingSaga/launch.conf or .env)
# - CLI flags: --fullscreen, --resolution WxH, --gamemode, --prime,
#              --check-libs, --x11/--wayland, --title, --log, --dry-run,
#              --no-exec, --enable-core-dumps
# - Auto-detect Unity engine and map friendly flags to Unity args
# - LD_LIBRARY_PATH augmentation (./lib, ./Plugins)
# - Optional GameMode integration (gamemoderun)
# ------------------------------------------------------------------------------

set -Eeuo pipefail
IFS=$'\n\t'

# ---------------------------
# Utility & Defaults
# ---------------------------

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly GAME_NAME_DEFAULT="VikingSaga"
GAME_NAME="${GAME_NAME:-$GAME_NAME_DEFAULT}"

# Executable resolution (can be overridden via GAME_EXE env/flag)
DEFAULT_EXE="$SCRIPT_DIR/${GAME_NAME}.x86_64"
GAME_EXE="${GAME_EXE:-$DEFAULT_EXE}"

# XDG paths (logs/config/state)
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
APP_CFG_DIR="$XDG_CONFIG_HOME/$GAME_NAME"
APP_STATE_DIR="$XDG_STATE_HOME/$GAME_NAME"
mkdir -p "$APP_CFG_DIR" "$APP_STATE_DIR"

LOG_FILE="${LOG_FILE:-$APP_STATE_DIR/launch.log}"

# Logger
log() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*"; }
info() { log "INFO  | $*"; }
warn() { log "WARN  | $*" >&2; }
err()  { log "ERROR | $*" >&2; }

# Log rotation (simple: keep ~1 MiB max)
rotate_log() {
  local max=1048576
  if [[ -f "$LOG_FILE" ]] && [[ $(wc -c <"$LOG_FILE") -gt $max ]]; then
    mv -f "$LOG_FILE" "${LOG_FILE}.1" 2>/dev/null || true
  fi
}

# Terminal title
set_title() {
  local title=$1
  printf '\033]0;%s\a' "$title" || true
}

# Read .env-style config safely: KEY=VALUE lines
load_env_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  while IFS='=' read -r k v; do
    # skip comments/empty
    [[ -z "${k// }" || "$k" =~ ^\# ]] && continue
    # strip quotes around value if present
    v="${v%\"}"; v="${v#\"}"; v="${v%\'}"; v="${v#\'}"
    export "$k=$v"
  done <"$file"
}

# ---------------------------
# Load configuration
# ---------------------------

# Load env from app config directory and local .env (if present)
load_env_file "$APP_CFG_DIR/launch.conf"
load_env_file "$SCRIPT_DIR/.env"

# ---------------------------
# CLI parsing (GNU/long style)
# ---------------------------

FULLSCREEN="${FULLSCREEN:-false}"
RESOLUTION="${RESOLUTION:-}"       # e.g. 1920x1080
USE_GAMEMODE="${USE_GAMEMODE:-auto}"  # auto|true|false
FORCE_X11="${FORCE_X11:-false}"
FORCE_WAYLAND="${FORCE_WAYLAND:-false}"
CHECK_LIBS="${CHECK_LIBS:-false}"
USE_PRIME="${USE_PRIME:-false}"
DRY_RUN="${DRY_RUN:-false}"
NO_EXEC="${NO_EXEC:-false}"
ENABLE_CORES="${ENABLE_CORES:-false}"
CUSTOM_TITLE="${CUSTOM_TITLE:-$GAME_NAME}"
CUSTOM_LOG="${CUSTOM_LOG:-}"

print_help() {
  cat <<EOF
$GAME_NAME launcher

Usage: $0 [options] [--] [game-args...]

Options:
  --fullscreen, -f              Start fullscreen
  --resolution, -r  WxH         Set resolution, e.g. 1920x1080
  --x11 / --wayland             Force SDL/Unity video driver
  --gamemode[=true|false|auto]  Use Feral GameMode if available (default: auto)
  --prime                       Prefer discrete GPU (DRI_PRIME=1)
  --check-libs                  Run ldd and warn about missing libs
  --enable-core-dumps           ulimit -c unlimited (debugging)
  --title        STRING         Set window/terminal title
  --log          FILE           Log to custom file (default: $LOG_FILE)
  --dry-run                     Print what would run, then exit
  --no-exec                     Do not replace the shell; return game's exit code
  --exe          PATH           Path to the game executable
  --help, -h                    Show this help
EOF
}

# Minimal long option parser
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fullscreen|-f) FULLSCREEN=true; shift ;;
    --resolution|-r) RESOLUTION="${2:-}"; shift 2 ;;
    --x11)           FORCE_X11=true; FORCE_WAYLAND=false; shift ;;
    --wayland)       FORCE_WAYLAND=true; FORCE_X11=false; shift ;;
    --gamemode)      USE_GAMEMODE=true; shift ;;
    --gamemode=*)    USE_GAMEMODE="${1#*=}"; shift ;;
    --prime)         USE_PRIME=true; shift ;;
    --check-libs)    CHECK_LIBS=true; shift ;;
    --enable-core-dumps) ENABLE_CORES=true; shift ;;
    --title)         CUSTOM_TITLE="${2:-$GAME_NAME}"; shift 2 ;;
    --log)           CUSTOM_LOG="${2:-}"; shift 2 ;;
    --dry-run)       DRY_RUN=true; shift ;;
    --no-exec)       NO_EXEC=true; shift ;;
    --exe)           GAME_EXE="${2:-$GAME_EXE}"; shift 2 ;;
    --help|-h)       print_help; exit 0 ;;
    --)              shift; break ;;
    *)               break ;;
  esac
done

[[ -n "$CUSTOM_LOG" ]] && LOG_FILE="$CUSTOM_LOG"
rotate_log

# ---------------------------
# Environment prep
# ---------------------------

# Reset + title
printf '\033c' || true
set_title "$CUSTOM_TITLE"

# LD_LIBRARY_PATH augmentation (local bundled libs)
if [[ -d "$SCRIPT_DIR/lib" ]]; then
  export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:${LD_LIBRARY_PATH:-}"
  info "Added $SCRIPT_DIR/lib to LD_LIBRARY_PATH"
fi
if [[ -d "$SCRIPT_DIR/Plugins" ]]; then
  export LD_LIBRARY_PATH="$SCRIPT_DIR/Plugins:${LD_LIBRARY_PATH:-}"
  info "Added $SCRIPT_DIR/Plugins to LD_LIBRARY_PATH"
fi

# Prefer discrete GPU if requested (Mesa/PRIME)
if [[ "$USE_PRIME" == "true" ]]; then
  export DRI_PRIME=1
  info "DRI_PRIME=1 (discrete GPU preferred)"
fi

# Wayland/X11 preference (helps SDL & Unity)
if [[ "$FORCE_X11" == "true" ]]; then
  export SDL_VIDEODRIVER=x11
  info "SDL_VIDEODRIVER=x11 (forcing X11)"
elif [[ "$FORCE_WAYLAND" == "true" ]]; then
  export SDL_VIDEODRIVER=wayland
  info "SDL_VIDEODRIVER=wayland (forcing Wayland)"
fi

# Core dumps for debugging
if [[ "$ENABLE_CORES" == "true" ]]; then
  ulimit -c unlimited || warn "Could not enable core dumps"
fi

# GameMode support
GAMEMODE_PREFIX=()
if [[ "$USE_GAMEMODE" == "true" || "$USE_GAMEMODE" == "auto" ]]; then
  if command -v gamemoderun >/dev/null 2>&1; then
    GAMEMODE_PREFIX=(gamemoderun)
    info "Using Feral GameMode"
  elif [[ "$USE_GAMEMODE" == "true" ]]; then
    warn "gamemoderun not found, continuing without GameMode"
  fi
fi

# ---------------------------
# Executable checks
# ---------------------------

# If GAME_EXE not found, try to find any .x86_64 in folder
if [[ ! -f "$GAME_EXE" ]]; then
  alt="$(printf '%s\n' "$SCRIPT_DIR/"*.x86_64 2>/dev/null | head -n1 || true)"
  if [[ -n "${alt:-}" && -f "$alt" ]]; then
    warn "Executable not found at $GAME_EXE; using detected $alt"
    GAME_EXE="$alt"
  else
    err "Executable not found: $GAME_EXE"
    exit 1
  fi
fi

# Ensure executable bit
if [[ ! -x "$GAME_EXE" ]]; then
  info "Setting execute permissions on $GAME_EXE"
  chmod +x "$GAME_EXE" || { err "Failed to chmod +x $GAME_EXE"; exit 1; }
fi

# Optional dependencies checks
if [[ "$CHECK_LIBS" == "true" ]]; then
  if command -v ldd >/dev/null 2>&1; then
    missing="$(ldd "$GAME_EXE" | awk '/not found/{print $1}')"
    if [[ -n "$missing" ]]; then
      warn "Missing shared libraries detected:"
      while read -r lib; do printf '  - %s\n' "$lib"; done <<<"$missing" >&2
    else
      info "No missing shared libraries reported by ldd."
    fi
  fi
  if ! command -v glxinfo >/dev/null 2>&1; then
    warn "glxinfo not found (mesa-utils). OpenGL diagnostics unavailable."
  fi
fi

# ---------------------------
# Engine detection & arg mapping
# ---------------------------

is_unity=false
if [[ -f "$SCRIPT_DIR/UnityPlayer.so" || -f "$SCRIPT_DIR/UnityCrashHandler64" ]]; then
  is_unity=true
fi

# Build arguments
declare -a GAME_ARGS=()

# Friendly flags → engine-specific args
if [[ "$FULLSCREEN" == "true" ]]; then
  if $is_unity; then
    GAME_ARGS+=(-screen-fullscreen 1)
  else
    GAME_ARGS+=(--fullscreen)
  fi
fi

if [[ -n "$RESOLUTION" ]]; then
  if [[ "$RESOLUTION" =~ ^([0-9]+)x([0-9]+)$ ]]; then
    WIDTH="${BASH_REMATCH[1]}"; HEIGHT="${BASH_REMATCH[2]}"
    if $is_unity; then
      GAME_ARGS+=(-screen-width "$WIDTH" -screen-height "$HEIGHT")
    else
      GAME_ARGS+=(--resolution "${WIDTH}x${HEIGHT}")
    fi
  else
    warn "Invalid resolution format '$RESOLUTION' (expected WxH), ignoring."
  fi
fi

# Pass remaining user args through
[[ $# -gt 0 ]] && GAME_ARGS+=("$@")

# ---------------------------
# Launch
# ---------------------------

set_title "$CUSTOM_TITLE"
info "Executable : $GAME_EXE"
info "Arguments  : ${GAME_ARGS[*]:-<none>}"
info "Log file   : $LOG_FILE"

# Log the launch attempt
{
  printf -- "-----\n"
  log "Launching $GAME_NAME"
  log "Exe : $GAME_EXE"
  log "Args: ${GAME_ARGS[*]:-<none>}"
  log "CWD : $SCRIPT_DIR"
} >>"$LOG_FILE"

if [[ "$DRY_RUN" == "true" ]]; then
  info "[DRY RUN] Command would be:"
  printf '  %q ' "${GAMEMODE_PREFIX[@]}" "$GAME_EXE" "${GAME_ARGS[@]}"; printf '\n'
  exit 0
fi

# Use no-exec mode to capture exit codes, otherwise replace shell
if [[ "$NO_EXEC" == "true" ]]; then
  set +e
  "${GAMEMODE_PREFIX[@]}" "$GAME_EXE" "${GAME_ARGS[@]}" 2>&1 | tee -a "$LOG_FILE"
  rc=${PIPESTATUS[0]}
  set -e
  if [[ $rc -ne 0 ]]; then
    err "Game exited with code $rc"
  else
    info "Game exited cleanly."
  fi
  exit "$rc"
else
  # Append stdout/stderr to log and replace shell
  # shellcheck disable=SC2093
  exec "${GAMEMODE_PREFIX[@]}" "$GAME_EXE" "${GAME_ARGS[@]}" >>"$LOG_FILE" 2>&1
fi
