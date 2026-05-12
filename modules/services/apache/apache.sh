#!/bin/bash
# =============================================================================
# modules/services/apache/apache.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
APACHE_LABEL="Apache"
APACHE_SERVICE="apache2"
APACHE_PACKAGE="apache2"
APACHE_SVC_VAR="SVC_APACHE"
APACHE_GROUP="web"
APACHE_ENTRY="apache_entry"

# --- Initialize status variable ----------------------------------------------
SVC_APACHE="not installed"

# --- Directory variables -----------------------------------------------------
APACHE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APACHE_ACTIONS_DIR="$APACHE_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_apache_installed() {
    pkg_installed "$APACHE_PACKAGE"
}

is_apache_running() {
    svc_running "$APACHE_SERVICE"
}

# --- Entry function ----------------------------------------------------------
apache_entry() {
    echo "Apache control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$APACHE_LABEL|$APACHE_SERVICE|$APACHE_PACKAGE|$APACHE_SVC_VAR|$APACHE_GROUP|$APACHE_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$APACHE_DIR"