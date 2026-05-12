#!/bin/bash
# =============================================================================
# modules/services/dovecot/dovecot.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
DOVECOT_LABEL="Dovecot"
DOVECOT_SERVICE="dovecot"
DOVECOT_PACKAGE="dovecot-core"
DOVECOT_SVC_VAR="SVC_DOVECOT"
DOVECOT_GROUP="mail"
DOVECOT_ENTRY="dovecot_entry"

# --- Initialize status variable ----------------------------------------------
SVC_DOVECOT="not installed"

# --- Directory variables -----------------------------------------------------
DOVECOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOVECOT_ACTIONS_DIR="$DOVECOT_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_dovecot_installed() {
    pkg_installed "$DOVECOT_PACKAGE"
}

is_dovecot_running() {
    svc_running "$DOVECOT_SERVICE"
}

# --- Entry function ----------------------------------------------------------
dovecot_entry() {
    echo "Dovecot control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$DOVECOT_LABEL|$DOVECOT_SERVICE|$DOVECOT_PACKAGE|$DOVECOT_SVC_VAR|$DOVECOT_GROUP|$DOVECOT_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$DOVECOT_DIR"