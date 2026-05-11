#!/bin/bash
# =============================================================================
# modules/services/mysql/actions/mysql_list_databases.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_mysql_list_databases() {
    

    if ! pkg_installed "mysql-server"; then
        warn "MySQL is not installed."
        return 1
    fi

    if ! systemctl is-active --quiet mysql; then
        warn "MySQL is not running."
        return 1
    fi

	section "MySQL Databases"

    local databases
    databases=$(mysql -u root -e "SHOW DATABASES;" 2>/dev/null | grep -v "^Database$\|information_schema\|performance_schema\|sys")

    if [ -z "$databases" ]; then
        info "No user databases found."
        return 0
    fi

    echo ""
    echo "$databases" | while read -r db; do
        local size
        size=$(mysql -u root -e "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) FROM information_schema.tables WHERE table_schema='${db}';" 2>/dev/null | grep -v "^ROUND")
        printf "    %-30s %s MB\n" "$db" "${size:-0}"
    done
    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "List MySQL Databases|mysql_list_databases|action_mysql_list_databases"