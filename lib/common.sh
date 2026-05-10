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


export -f info warn error