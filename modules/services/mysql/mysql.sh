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





# --- Global Utility Functions ------------------------------------------------
is_mysql_installed(){
    pkg_installed "$MYSQL_PACKAGE"
}

is_mysql_running(){
    svc_running "$MYSQL_SERVICE"
}

MYSQL_MENU_OPTIONS=(
	"Install MySql|action_mysql_install"
	"Uninstall MySql|action_mysql_uninstall"
    "---|"
    "Start|action_mysql_start"
    "Stop|action_mysql_stop"
    "Restart|action_mysql_restart"
    "Enable on Boot|action_mysql_enable_on_boot"
    "Disable on Boot|action_mysql_disable_on_boot"
	"---|"
    "Backup Database|action_mysql_backup_database"
    "Create Database|action_mysql_create_database"
    "Delete Database|action_mysql_create_database"
    "Duplicate Database|action_mysql_duplicate_database"
    "Rename Database|action_mysql_rename_database"
	"List Databases|action_mysql_list_databases"
    "---|"
    "Create User|action_mysql_create_user"
    "Delete User|action_mysql_delete_user"
    "List Users|action_mysql_list_users"
    "---|"
    "Run Script|action_mysql_run_script"
    
)

mysql_entry() {
	command_menu MYSQL_MENU_OPTIONS "MySQL"
    
}

# --- Register ----------------------------------------------------------------
register_service "$MYSQL_LABEL|$MYSQL_SERVICE|$MYSQL_PACKAGE|$MYSQL_SVC_VAR|$MYSQL_GROUP|$MYSQL_ENTRY"


# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"