#!/bin/bash
# =============================================================================
# lib/common.sh — Shared Functions & Utilities
# Sourced by firstboot.sh and all modules
# Do not run directly
#
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Colors & formatting -----------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

export RED GREEN YELLOW CYAN BOLD NC

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

# section — prints a formatted section header
section() {
    echo ""
    echo -e "${CYAN}  ── ${BOLD}$1${NC}${CYAN} ───────────────────────────────────────${NC}"
    echo ""
}

export -f info warn error section