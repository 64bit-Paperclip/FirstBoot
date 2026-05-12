#!/bin/bash
# =============================================================================
# modules/services/fail2ban/fail2ban.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
FAIL2BAN_LABEL="Fail2ban"
FAIL2BAN_SERVICE="fail2ban"
FAIL2BAN_PACKAGE="fail2ban"
FAIL2BAN_SVC_VAR="SVC_FAIL2BAN"
FAIL2BAN_GROUP="security"
FAIL2BAN_ENTRY="fail2ban_entry"

# --- Initialize status variable ----------------------------------------------
SVC_FAIL2BAN="not installed"

# --- Directory variables -----------------------------------------------------
FAIL2BAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAIL2BAN_ACTIONS_DIR="$FAIL2BAN_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_fail2ban_installed() {
    pkg_installed "$FAIL2BAN_PACKAGE"
}

is_fail2ban_running() {
    svc_running "$FAIL2BAN_SERVICE"
}

# --- Entry function ----------------------------------------------------------
fail2ban_entry() {
    echo "Fail2ban control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$FAIL2BAN_LABEL|$FAIL2BAN_SERVICE|$FAIL2BAN_PACKAGE|$FAIL2BAN_SVC_VAR|$FAIL2BAN_GROUP|$FAIL2BAN_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$FAIL2BAN_DIR"