#!/bin/bash
# =============================================================================
# modules/actions/mysql_uninstall.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_mysql_uninstall() {
    section "Uninstalling MySQL"

    if ! pkg_installed "mysql-server"; then
        warn "MySQL is not installed."
        return 1
    fi

    confirm "This will remove MySQL and ALL its data. Are you sure?" || return 1
    confirm "Are you absolutely sure? This cannot be undone." || return 1

    info "Stopping MySQL..."
    systemctl stop mysql
    systemctl disable mysql

    info "Removing MySQL packages..."
    apt purge -y mysql-server mysql-client mysql-common
    apt autoremove -y

    info "Removing MySQL data and config..."
    rm -rf /etc/mysql /var/lib/mysql /var/log/mysql

    info "MySQL uninstalled."
}

# --- Register ----------------------------------------------------------------
register_action "Uninstall MySQL|mysql_uninstall|action_mysql_uninstall"