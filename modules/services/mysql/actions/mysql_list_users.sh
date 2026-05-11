#!/bin/bash
# =============================================================================
# modules/services/mysql/actions/mysql_list_users.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_mysql_list_users() {
    

    if ! pkg_installed "mysql-server"; then
        warn "MySQL is not installed."
        return 1
    fi

    if ! systemctl is-active --quiet mysql; then
        warn "MySQL is not running."
        return 1
    fi

	section "MySQL Users"

    local users
    users=$(mysql -u root -e "SELECT User, Host, plugin FROM mysql.user ORDER BY User;" 2>/dev/null)

    if [ -z "$users" ]; then
        warn "No users found."
        return 0
    fi

    echo ""
    printf "    %-20s %-30s %s\n" "User" "Host" "Auth Plugin"
    printf "    %-20s %-30s %s\n" "────────────────────" "──────────────────────────────" "───────────────────"
    echo "$users" | tail -n +2 | while IFS=$'\t' read -r user host plugin; do
        printf "    %-20s %-30s %s\n" "$user" "$host" "$plugin"
    done
    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "List MySQL Users|mysql_list_users|action_mysql_list_users"