#!/bin/bash
# =============================================================================
# modules/services/clamav/clamav.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
CLAMAV_LABEL="ClamAV"
CLAMAV_SERVICE="clamav-daemon"
CLAMAV_PACKAGE="clamav"
CLAMAV_SVC_VAR="SVC_CLAMAV"
CLAMAV_GROUP="mail,security"
CLAMAV_ENTRY="clamav_entry"

# --- Initialize status variable ----------------------------------------------
SVC_CLAMAV="not installed"

# --- Directory variables -----------------------------------------------------
CLAMAV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAMAV_ACTIONS_DIR="$CLAMAV_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_clamav_installed() {
    pkg_installed "$CLAMAV_PACKAGE"
}

is_clamav_running() {
    svc_running "$CLAMAV_SERVICE"
}

# --- Entry function ----------------------------------------------------------
clamav_entry() {
    echo "ClamAV control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$CLAMAV_LABEL|$CLAMAV_SERVICE|$CLAMAV_PACKAGE|$CLAMAV_SVC_VAR|$CLAMAV_GROUP|$CLAMAV_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$CLAMAV_DIR"
