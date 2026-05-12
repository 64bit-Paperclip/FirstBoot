#!/bin/bash
# =============================================================================
# modules/services/postfix/postfix.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
POSTFIX_LABEL="Postfix"
POSTFIX_SERVICE="postfix"
POSTFIX_PACKAGE="postfix"
POSTFIX_SVC_VAR="SVC_POSTFIX"
POSTFIX_GROUP="mail"
POSTFIX_ENTRY="postfix_entry"

# --- Initialize status variable ----------------------------------------------
SVC_POSTFIX="not installed"

# --- Directory variables -----------------------------------------------------
POSTFIX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POSTFIX_ACTIONS_DIR="$POSTFIX_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_postfix_installed() {
    pkg_installed "$POSTFIX_PACKAGE"
}

is_postfix_running() {
    svc_running "$POSTFIX_SERVICE"
}

# --- Entry function ----------------------------------------------------------
postfix_entry() {
    echo "Postfix control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$POSTFIX_LABEL|$POSTFIX_SERVICE|$POSTFIX_PACKAGE|$POSTFIX_SVC_VAR|$POSTFIX_GROUP|$POSTFIX_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$POSTFIX_DIR"