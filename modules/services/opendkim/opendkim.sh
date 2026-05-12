#!/bin/bash
# =============================================================================
# modules/services/opendkim/opendkim.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
OPENDKIM_LABEL="OpenDKIM"
OPENDKIM_SERVICE="opendkim"
OPENDKIM_PACKAGE="opendkim"
OPENDKIM_SVC_VAR="SVC_OPENDKIM"
OPENDKIM_GROUP="mail"
OPENDKIM_ENTRY="opendkim_entry"

# --- Initialize status variable ----------------------------------------------
SVC_OPENDKIM="not installed"

# --- Directory variables -----------------------------------------------------
OPENDKIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENDKIM_ACTIONS_DIR="$OPENDKIM_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_opendkim_installed() {
    pkg_installed "$OPENDKIM_PACKAGE"
}

is_opendkim_running() {
    svc_running "$OPENDKIM_SERVICE"
}

# --- Entry function ----------------------------------------------------------
opendkim_entry() {
    echo "OpenDKIM control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$OPENDKIM_LABEL|$OPENDKIM_SERVICE|$OPENDKIM_PACKAGE|$OPENDKIM_SVC_VAR|$OPENDKIM_GROUP|$OPENDKIM_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$OPENDKIM_DIR"