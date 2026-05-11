#!/bin/bash
# =============================================================================
# modules/mysql.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# TODO: not yet implemented
# =============================================================================

# --- Source actions ----------------------------------------------------------
MYSQL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _file in $(ls "$MYSQL_DIR/actions"/*.sh 2>/dev/null | sort); do
    [ -f "$_file" ] && source "$_file"
done
unset _file MYSQL_DIR


MYSQL_MENU_OPTIONS=(
	"Install MySql|action_install_mysql"
    "List Databases|action_mysql_list_databases"
    "Create Database|action_mysql_create_database"
    "Drop Database|action_mysql_drop_database"
    "List Users|action_mysql_list_users"
    "Create User|action_mysql_create_user"
    "Drop User|action_mysql_drop_user"
    "Configure|mysql_configure"
    "Status|mysql_status"
)

mysql_entry() {
	command_menu MYSQL_MENU_OPTIONS "MySQL"
    
}

# --- Register ----------------------------------------------------------------
register_service "MySQL|mysql|mysql-server|SVC_MYSQL|database|mysql_entry"