#!/bin/bash
# =============================================================================
# modules/services/mysql/actions/mysql_create_database.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================





# --- Action ------------------------------------------------------------------
action_mysql_create_database() {
    

    if ! pkg_installed "mysql-server"; then
        warn "MySQL is not installed."
        return 1
    fi

	section "Create MySQL Database"
	
    required_prompt "Database name" DB_CREATE_NAME

    # Check if database already exists
    if mysql -u root -e "SHOW DATABASES;" 2>/dev/null | grep -q "^${DB_CREATE_NAME}$"; then
        warn "Database '$DB_CREATE_NAME' already exists."
        return 1
    fi

    mysql -u root <<EOF || { error "Failed to create database."; return 1; }
CREATE DATABASE \`${DB_CREATE_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF

    info "Database '$DB_CREATE_NAME' created."
    unset DB_CREATE_NAME
}

# --- Register ----------------------------------------------------------------
register_action "Create MySQL Database|mysql_create_database|action_mysql_create_database"