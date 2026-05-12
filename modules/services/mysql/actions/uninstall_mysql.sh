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

    run_system_cmd systemctl stop mysql || { error "Failed to stop MySQL."; return 1; }
    run_system_cmd systemctl disable mysql || { error "Failed to disable MySQL."; return 1; }

    info "Removing MySQL packages..."
    run_system_cmd apt purge -y mysql-server mysql-client mysql-common || { error "Failed to purge MySQL packages."; return 1; }
    run_system_cmd apt autoremove -y || { error "Failed to autoremove packages."; return 1; }

    info "Removing MySQL data and config..."
    run_system_cmd rm -rf /etc/mysql /var/lib/mysql /var/log/mysql || { error "Failed to remove MySQL data."; return 1; }

    info "MySQL uninstalled."
}

# --- Register ----------------------------------------------------------------
register_action "Uninstall MySQL|mysql_uninstall|action_mysql_uninstall"