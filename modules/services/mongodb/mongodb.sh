#!/bin/bash
# =============================================================================
# modules/services/mongodb/mongodb.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
MONGODB_LABEL="MongoDB"
MONGODB_SERVICE="mongod"
MONGODB_PACKAGE="mongodb-org"
MONGODB_SVC_VAR="SVC_MONGODB"
MONGODB_GROUP="database"
MONGODB_ENTRY="mongodb_entry"

# --- Initialize status variable ----------------------------------------------
SVC_MONGODB="not installed"

# --- Directory variables -----------------------------------------------------
MONGODB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONGODB_ACTIONS_DIR="$MONGODB_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_mongodb_installed() {
    pkg_installed "$MONGODB_PACKAGE"
}

is_mongodb_running() {
    svc_running "$MONGODB_SERVICE"
}

# --- Dynamic menu ------------------------------------------------------------
_mongodb_generate_menu_options() {
    local -n _out="$1"
    _out=()

    if is_mongodb_installed; then
        _out+=("Uninstall MongoDB|action_mongodb_uninstall")
    else
        _out+=("Install MongoDB|action_mongodb_install")
        return 0
    fi

    _out+=("---|")

    if is_mongodb_running; then
        _out+=("Stop|action_mongodb_stop")
        _out+=("Restart|action_mongodb_restart")
    else
        _out+=("Start|action_mongodb_start")
    fi

    _out+=("Status|action_mongodb_status")
    _out+=("Enable on Boot|action_mongodb_enable")
    _out+=("Disable on Boot|action_mongodb_disable")
    _out+=("---|")
    _out+=("Create Database|action_mongodb_create_database")
    _out+=("List Databases|action_mongodb_list_databases")
    _out+=("Delete Database|action_mongodb_delete_database")
    _out+=("---|")
    _out+=("Create User|action_mongodb_create_user")
    _out+=("Delete User|action_mongodb_delete_user")
    _out+=("List Users|action_mongodb_list_users")
}

# --- Entry function ----------------------------------------------------------
mongodb_entry() {
    dynamic_command_menu _mongodb_generate_menu_options "MongoDB"
}

# --- Register ----------------------------------------------------------------
register_service "$MONGODB_LABEL|$MONGODB_SERVICE|$MONGODB_PACKAGE|$MONGODB_SVC_VAR|$MONGODB_GROUP|$MONGODB_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$MONGODB_DIR"