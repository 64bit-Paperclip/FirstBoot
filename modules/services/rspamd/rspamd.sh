#!/bin/bash
# =============================================================================
# modules/services/rspamd/rspamd.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
RSPAMD_LABEL="Rspamd"
RSPAMD_SERVICE="rspamd"
RSPAMD_PACKAGE="rspamd"
RSPAMD_SVC_VAR="SVC_RSPAMD"
RSPAMD_GROUP="mail"
RSPAMD_ENTRY="rspamd_entry"

# --- Initialize status variable ----------------------------------------------
SVC_RSPAMD="not installed"

# --- Directory variables -----------------------------------------------------
RSPAMD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RSPAMD_ACTIONS_DIR="$RSPAMD_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_rspamd_installed() {
    pkg_installed "$RSPAMD_PACKAGE"
}

is_rspamd_running() {
    svc_running "$RSPAMD_SERVICE"
}

# --- Entry function ----------------------------------------------------------
rspamd_entry() {
    echo "Rspamd control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$RSPAMD_LABEL|$RSPAMD_SERVICE|$RSPAMD_PACKAGE|$RSPAMD_SVC_VAR|$RSPAMD_GROUP|$RSPAMD_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$RSPAMD_DIR"