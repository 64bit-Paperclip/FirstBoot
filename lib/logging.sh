#!/bin/bash
# =============================================================================
# lib/logging.sh — logging functions & utilities
# Sourced by firstboot.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

log() {

    [[ -z "$1" ]] && return 1
    [[ -z "$2" ]] && return 1

    local level="$1"
    local message="$2"
    local timestamp

    message=$(strip_escape_codes "$2")

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}


# --- Logging functions -------------------------------------------------------

# info — general status message
info() {
    [[ -z "$1" ]] && return 1
    echo -e "${GREEN}[+]${NC} $1"
}

# warn — non-fatal warning
warn() {
    [[ -z "$1" ]] && return 1
    echo -e "${YELLOW}[!]${NC} $1"
}

# error — non-fatal error
error() {
    [[ -z "$1" ]] && return 1
    echo -e "${RED}[✗]${NC} $1"
    log "ERROR" "$1"
}

# error_and_exit — fatal error, exits immediately
error_and_exit() {
    [[ -z "$1" ]] && exit 1
    echo -e "${RED}[✗]${NC} $1"
    log "ERROR" "$1"
    exit 1
}