#!/bin/bash
# =============================================================================
# modules/mysql.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# TODO: not yet implemented
# =============================================================================

# --- Initialize status variable ----------------------------------------------
SVC_MYSQL="not installed"

# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


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

# --- Register ----------------------------------------------------------------
register_service "MySQL|mysql|mysql-server|SVC_MYSQL|database|mysql_entry"