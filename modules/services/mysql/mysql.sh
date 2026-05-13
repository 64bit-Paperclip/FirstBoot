#!/bin/bash
# =============================================================================
# modules/mysql.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# TODO: not yet implemented
# =============================================================================

# --- Service variables -------------------------------------------------------
MYSQL_LABEL="MySQL"
MYSQL_SERVICE="mysql"
MYSQL_PACKAGE="mysql-server"
MYSQL_SVC_VAR="SVC_MYSQL"
MYSQL_GROUP="database"
MYSQL_ENTRY="mysql_entry"

# --- Initialize status variable ----------------------------------------------
SVC_MYSQL="not installed"

# --- Directory variables -----------------------------------------------------
MYSQL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYSQL_ACTIONS_DIR="$MYSQL_DIR/actions"
MYSQL_UTILITIES_DIR="$MYSQL_DIR/utilities"

# --- Include Utilities -------------------------------------------------------
source "$MYSQL_UTILITIES_DIR/mysql_utilities.sh"



# --- Global Utility Functions ------------------------------------------------
is_mysql_installed(){
    pkg_installed "$MYSQL_PACKAGE"
}

is_mysql_running(){
    svc_running "$MYSQL_SERVICE"
}

# --- Dynamic menu ------------------------------------------------------------
_mysql_generate_menu_options() {
    local -n _out="$1"
    _out=()

    if is_mysql_installed; then
        _out+=("Uninstall MySQL|action_mysql_uninstall")
    else
        _out+=("Install MySQL|action_mysql_install")
        return 0
    fi

    _out+=("---|Manage Service")

    if is_mysql_running; then
        _out+=("Stop Service|action_mysql_stop")
        _out+=("Restart Service|action_mysql_restart")
    else
        _out+=("Start Service|action_mysql_start")
    fi

    _out+=("Enable on Boot|action_mysql_enable_on_boot")
    _out+=("Disable on Boot|action_mysql_disable_on_boot")
    _out+=("Status|action_mysql_status")
    _out+=("---|Manage Databases")
    _out+=("Backup Database|action_mysql_backup_database")
    _out+=("Create Database|action_mysql_create_database")
    _out+=("Delete Database|action_mysql_delete_database")
    _out+=("Duplicate Database|action_mysql_duplicate_database")
    _out+=("List Databases|action_mysql_list_databases")
    _out+=("Rename Database|action_mysql_rename_database")
    _out+=("---|Manage Users")
    _out+=("Create MySql User|action_mysql_create_user")
    _out+=("Delete MySql User|action_mysql_delete_user")
    _out+=("List Users|action_mysql_list_users")
    _out+=("---|")
    _out+=("Run Script|action_mysql_run_script")
}

# --- Entry function ----------------------------------------------------------
mysql_entry() {
    dynamic_command_menu _mysql_generate_menu_options "MySQL"
}

# --- Register ----------------------------------------------------------------
register_service "$MYSQL_LABEL|$MYSQL_SERVICE|$MYSQL_PACKAGE|$MYSQL_SVC_VAR|$MYSQL_GROUP|$MYSQL_ENTRY"


# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"