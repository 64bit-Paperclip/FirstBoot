#!/bin/bash
# =============================================================================
# lib/common.sh — Shared Functions & Utilities
# Sourced by firstboot.sh and all modules
# Do not run directly
#
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Logging functions -------------------------------------------------------

# info — general status message
info() {
    echo -e "${GREEN}[+]${NC} $1"
}

# warn — non-fatal warning
warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# error — fatal error, exits immediately
error() {
    echo -e "${RED}[✗]${NC} $1"
    exit 1
}

# Check if current user is logged in directly as root
is_user_root() {
    [ "$UID" -eq 0 ]
}

# Check if current user has sudo privileges
is_user_super_user() {
    [ "$EUID" -eq 0 ]
}

is_firstboot_installed() {
    [ "$FIRSTBOOT_SCRIPT_DIR" = "$FIRSTBOOT_INSTALL_DIR" ]
}

is_firstboot_portable() {
    ! is_firstboot_installed
}

has_sudo_users() {
    getent group sudo | cut -d: -f4 | tr ',' '\n' | grep -q .
}