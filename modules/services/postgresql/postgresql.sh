#!/bin/bash
# =============================================================================
# modules/services/postgresql/postgresql.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
POSTGRESQL_LABEL="PostgreSQL"
POSTGRESQL_SERVICE="postgresql"
POSTGRESQL_PACKAGE="postgresql"
POSTGRESQL_SVC_VAR="SVC_POSTGRESQL"
POSTGRESQL_GROUP="database"
POSTGRESQL_ENTRY="postgresql_entry"

# --- Initialize status variable ----------------------------------------------
SVC_POSTGRESQL="not installed"

# --- Directory variables -----------------------------------------------------
POSTGRESQL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POSTGRESQL_ACTIONS_DIR="$POSTGRESQL_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_postgresql_installed() {
    pkg_installed "$POSTGRESQL_PACKAGE"
}

is_postgresql_running() {
    svc_running "$POSTGRESQL_SERVICE"
}

# --- Entry function ----------------------------------------------------------
postgresql_entry() {
    echo "PostgreSQL control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$POSTGRESQL_LABEL|$POSTGRESQL_SERVICE|$POSTGRESQL_PACKAGE|$POSTGRESQL_SVC_VAR|$POSTGRESQL_GROUP|$POSTGRESQL_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$POSTGRESQL_DIR"