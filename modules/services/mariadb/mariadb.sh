#!/bin/bash
# =============================================================================
# modules/services/mariadb/mariadb.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
MARIADB_LABEL="MariaDB"
MARIADB_SERVICE="mariadb"
MARIADB_PACKAGE="mariadb-server"
MARIADB_SVC_VAR="SVC_MARIADB"
MARIADB_GROUP="database"
MARIADB_ENTRY="mariadb_entry"

# --- Initialize status variable ----------------------------------------------
SVC_MARIADB="not installed"

# --- Directory variables -----------------------------------------------------
MARIADB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARIADB_ACTIONS_DIR="$MARIADB_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_mariadb_installed() {
    pkg_installed "$MARIADB_PACKAGE"
}

is_mariadb_running() {
    svc_running "$MARIADB_SERVICE"
}

# --- Entry function ----------------------------------------------------------
mariadb_entry() {
    echo "MariaDB control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$MARIADB_LABEL|$MARIADB_SERVICE|$MARIADB_PACKAGE|$MARIADB_SVC_VAR|$MARIADB_GROUP|$MARIADB_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$MARIADB_DIR"