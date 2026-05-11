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


# --- Register ----------------------------------------------------------------
register_service "$MYSQL_LABEL|$MYSQL_SERVICE|$MYSQL_PACKAGE|$MYSQL_SVC_VAR|$MYSQL_GROUP|$MYSQL_ENTRY"


# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# --- Global Utility Functions ------------------------------------------------
is_mysql_installed(){
    pkg_installed "$MYSQL_PACKAGE"
}

is_mysql_running(){
    svc_running "$MYSQL_SERVICE"
}



MYSQL_MENU_OPTIONS=(
	"Install MySql|action_install_mysql"
	"Uninstall MySql|action_uninstall_mysql"
	"---|"
    "Create Database|action_mysql_create_database"
	"List Databases|action_mysql_list_databases"
    "---|"
    "List Users|action_mysql_list_users"
    "Create User|action_mysql_create_user"
)

mysql_entry() {
	command_menu MYSQL_MENU_OPTIONS "MySQL"
    
}

